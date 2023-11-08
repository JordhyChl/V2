//HOME

// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, prefer_const_constructors, avoid_function_literals_in_foreach_calls, depend_on_referenced_packages, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, prefer_final_fields

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gif_view/gif_view.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/assetmarker.model.dart';
import 'package:gpsid/model/currentpoin.sspoin.model.dart';
import 'package:gpsid/model/banner.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getclara.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/localnotif.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/profile.model.dart';
import 'package:gpsid/model/unit.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/model/vehiclestatus.model.dart';
import 'package:gpsid/pages/choosevehicle.topup.dart';
import 'package:gpsid/pages/notification.dart';
import 'package:gpsid/pages/landingCart.dart';
import 'package:gpsid/pages/otherpage.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/status_unit.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  int selected;
  bool darkMode;
  bool secondAccess;
  HomePage(
      {super.key,
      required this.selected,
      required this.darkMode,
      required this.secondAccess});

  @override
  State<HomePage> createState() => _HomePageState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationplugin =
    FlutterLocalNotificationsPlugin();

class _HomePageState extends State<HomePage> {
  var size, height, width;
  int selected = 0;
  bool isSelected = false;
  bool _isError = false;
  String _errCode = '';
  late ErrorTrapModel _errorMessage;
  late Future<dynamic> _getBanner;
  late Future<dynamic> _getProduct;
  late Future<dynamic> _getMoving;
  late Future<dynamic> _getPark;
  late Future<dynamic> _getStop;
  late Future<dynamic> _getNoData;
  late Future<dynamic> _getReadAlarm;
  LocalData data = LocalData(
      ID: 0,
      SeenId: 0,
      Username: '',
      Password: '',
      Fullname: '',
      Phone: '',
      Email: '',
      Addres: '',
      CompanyName: '',
      BranchId: 0,
      Privilage: 0,
      Token: '',
      IsGenerated: false,
      IsGoogle: false,
      IsApple: false,
      createdAt: '');
  late Future<dynamic> _getLocal;
  late Future<dynamic> _getPoin;
  SSPOINCurrentPoinModel ssPoin = SSPOINCurrentPoinModel(
      status: false,
      message: '',
      data: DataSSPoin(id: 0, currentPoint: 0, isBlock: false));
  late LinkModel url;
  bool disableSSpoin = false;
  bool bannerLoading = false;
  bool movingLoading = false;
  bool parkLoading = false;
  bool stopLoading = false;
  bool lostLoading = false;
  bool sspoinLoading = false;
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.goodMorning;
    }
    if (hour < 14) {
      return AppLocalizations.of(context)!.goodAfternoon;
    }
    if (hour < 18) {
      return AppLocalizations.of(context)!.goodEvening;
    }
    return AppLocalizations.of(context)!.goodNight;
  }

  String getSSPoin = '';
  var pressCount = 0;
  bool newUpdate = false;
  bool emailVerif = true;
  bool completeProfile = false;
  int progressCount = 0;
  String imeiDemo = '';

  @override
  void initState() {
    super.initState();
    // _getReadAlarm = getReadAlarm();
    getVehicleList();
    readTheme();
    getVersionCheck();
    _getBanner = getBanner();
    // _getProduct = getProduct();
    _getMoving = getMoving();
    _getPark = getPark();
    _getStop = getStop();
    _getNoData = getNoData();
    _getLocal = getLocal();
    _getPoin = getPoin();
    selected = widget.selected;
    checkPermission();
    getPermission();
    Platform.isAndroid ? getReadNotif() : {};
  }

  getVehicleList() async {
    final result = await APIService().getVehicleList(0, 0);
    if (result is VehicleListModel) {
      result.data.result.forEach((el) {
        if (el.imei == '123456') {
          setState(() {
            imeiDemo = el.imei;
          });
        }
      });
    }
  }

  verificationCheck() async {
    print(
        'Diff: ${DateTime.now().toLocal().difference(DateTime.parse(data.createdAt).toLocal()).inDays}');
    final result = await APIService().getProfile();
    if (result is ErrorTrapModel) {
      // setState(() {
      //   emailVerif = true;
      // });
    } else {
      if (result is ProfileModel) {
        if (result.data.result.preferensi.isNotEmpty) {
          setState(() {
            progressCount++;
          });
        }
        if (result.data.result.fullname.isNotEmpty) {
          setState(() {
            progressCount++;
          });
        }
        if (result.data.result.address.isNotEmpty) {
          setState(() {
            progressCount++;
          });
        }
        if (result.data.result.isVerifiedEmail) {
          setState(() {
            progressCount++;
          });
        }
        if (result.data.result.isVerifiedPhone) {
          setState(() {
            progressCount++;
          });
        }
        if (progressCount != 5) {
          setState(() {
            completeProfile = true;
          });
        }
        print(progressCount);
        if (!result.data.result.isVerifiedEmail &&
            !result.data.result.isVerifiedPhone) {
          if (DateTime.now()
                  .toLocal()
                  .difference(DateTime.parse(data.createdAt).toLocal())
                  .inDays >
              7) {
            showDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: AlertDialog(
                    backgroundColor: whiteCardColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifEmailPhone,
                            style: bold.copyWith(
                                fontSize: 12, color: blackPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.asset(
                            'assets/notverified.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifEmailPhoneSub,
                            style: reguler.copyWith(
                                fontSize: 12,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/verifEmailNow');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            width:
                                MediaQuery.of(context).size.width * (90 / 100),
                            decoration: BoxDecoration(
                                color: greenPrimary,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 1, color: greenPrimary)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: whiteColorDarkMode,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .verifEmailButton,
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: whiteColorDarkMode),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/verifyPhoneNumber');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            width:
                                MediaQuery.of(context).size.width * (90 / 100),
                            decoration: BoxDecoration(
                                color: greenPrimary,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 1, color: greenPrimary)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Icon(
                                      Icons.sim_card_outlined,
                                      color: whiteColorDarkMode,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.verifyPhone,
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: whiteColorDarkMode),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // else {
          //   setState(() {
          //     completeProfile = true;
          //   });
          // }
        } else if (!result.data.result.isVerifiedEmail) {
          if (DateTime.now()
                  .toLocal()
                  .difference(DateTime.parse(data.createdAt).toLocal())
                  .inDays >
              7) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: AlertDialog(
                    backgroundColor: whiteCardColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifEmailHome,
                            style: bold.copyWith(
                                fontSize: 12, color: blackPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.asset(
                            'assets/notverified.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifEmailSubHome,
                            style: reguler.copyWith(
                                fontSize: 12,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/verifEmailNow');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            width:
                                MediaQuery.of(context).size.width * (90 / 100),
                            decoration: BoxDecoration(
                                color: greenPrimary,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 1, color: greenPrimary)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: whiteColorDarkMode,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .verifEmailButton,
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: whiteColorDarkMode),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // else {
          //   setState(() {
          //     completeProfile = true;
          //   });
          // }
        } else if (!result.data.result.isVerifiedPhone) {
          if (DateTime.now()
                  .toLocal()
                  .difference(DateTime.parse(data.createdAt).toLocal())
                  .inDays >
              7) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: AlertDialog(
                    backgroundColor: whiteCardColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifPhoneHome,
                            style: bold.copyWith(
                                fontSize: 12, color: blackPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.asset(
                            'assets/notverified.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)!.verifPhoneSubHome,
                            style: reguler.copyWith(
                                fontSize: 12,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : blackSecondary3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/verifyPhoneNumber');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            width:
                                MediaQuery.of(context).size.width * (90 / 100),
                            decoration: BoxDecoration(
                                color: greenPrimary,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 1, color: greenPrimary)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Icon(
                                      Icons.sim_card_outlined,
                                      color: whiteColorDarkMode,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.verifyPhone,
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: whiteColorDarkMode),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // else {
          //   setState(() {
          //     completeProfile = true;
          //   });
          // }
        }
        // if (result.data.result.preferensi == '') {
        //   setState(() {
        //     completeProfile = true;
        //   });
        // }
        // if (result.data.result.isVerifiedEmail) {
        //   setState(() {
        //     emailVerif = true;
        //   });
        // } else {
        //   setState(() {
        //     emailVerif = false;
        //   });
        // }
      }
    }
  }

  initClara() async {
    // Dialogs().loadingDialog(context);
    setState(() {
      gettingData = false;
    });
    final claraDir = await path_provider.getApplicationDocumentsDirectory();
    String folderNameClara = 'Clara';
    final claraPath = Directory('${claraDir.path}/$folderNameClara');
    final resultClara = await APIService().getAsset();
    if (resultClara is AssetMarkerModel) {
      resultClara.data.results.forEach((el) async {
        el.clara.resultClara.forEach((clara) async {
          if (await claraPath.exists()) {
            print('Clara udah ada');
          } else {
            claraPath.create();
            final res = await http.get(Uri.parse(clara.iconClaraUrl));
            final imgName = '${clara.iconClaraId}_${clara.iconClaraName}.png';
            final localPath = path.join(claraPath.path, imgName);
            final imageFile = File(localPath);
            imageFile.writeAsBytes(res.bodyBytes);
          }
        });
      });
    }
    // claraDir = await path_provider.getApplicationDocumentsDirectory();
    final result = await APIService().getClara();
    print(result);
    if (result is GetClaraModel) {
      // Dialogs().hideLoaderDialog(context);
      setState(() {
        gettingData = true;
      });
      showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        backgroundColor: whiteColor,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: MediaQuery.of(context).viewInsets,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 30,
                                  color: blackPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Image.file(
                          File('${claraDir.path}/Clara/1_Clara.png'),
                          width: 160,
                          height: 160,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.claraTitle1} ${data.Fullname.isEmpty ? data.Username : data.Fullname}, ${AppLocalizations.of(context)!.claraTitle2}',
                          style:
                              bold.copyWith(fontSize: 16, color: blackPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          AppLocalizations.of(context)!.claraSubTitle,
                          style: reguler.copyWith(
                              fontSize: 12, color: blackPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    Visibility(
                      visible: result.dataClara.expired == 0 ? false : true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                widget.darkMode ? whiteCardColor : whiteColor,
                            // color: all ? blueGradient : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: redPrimary,
                            ),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${result.dataClara.expired} ${result.dataClara.expired > 1 ? AppLocalizations.of(context)!.units : AppLocalizations.of(context)!.unit} ${AppLocalizations.of(context)!.claraExpire}',
                                      style: bold.copyWith(
                                          fontSize: 12, color: blackPrimary)),
                                ],
                              )),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: result.dataClara.sevenday == 0 ? false : true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                widget.darkMode ? whiteCardColor : whiteColor,
                            // color: all ? blueGradient : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: yellowPrimary,
                            ),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${result.dataClara.sevenday} ${result.dataClara.sevenday > 1 ? AppLocalizations.of(context)!.units : AppLocalizations.of(context)!.unit} ${AppLocalizations.of(context)!.claraSevenday}',
                                      style: bold.copyWith(
                                          fontSize: 12, color: blackPrimary)),
                                ],
                              )),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: result.dataClara.threeday == 0 ? false : true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                widget.darkMode ? whiteCardColor : whiteColor,
                            // color: all ? blueGradient : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: bluePrimary,
                            ),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${result.dataClara.threeday} ${result.dataClara.threeday > 1 ? AppLocalizations.of(context)!.units : AppLocalizations.of(context)!.unit} ${AppLocalizations.of(context)!.claraThreeday}',
                                      style: bold.copyWith(
                                          fontSize: 12, color: blackPrimary)),
                                ],
                              )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
                        Navigator.pop(context);
                        // Navigator.pushNamed(context, '/choosevehicletopup');

                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ChooseVehicle(
                              darkMode: widget.darkMode,
                              fromClara: true,
                            );
                          },
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: blueGradient,
                            // color: all ? blueGradient : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: blueGradient,
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
                                      child: Text('Top Up',
                                          style: bold.copyWith(
                                              fontSize: 12,
                                              color: widget.darkMode
                                                  ? whiteColorDarkMode
                                                  : whiteColor)),
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
    } else {
      // Dialogs().hideLoaderDialog(context);
      setState(() {
        gettingData = true;
      });
    }
    data.Privilage == 4 ? verificationCheck() : {};
  }

  readTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
    final bool? darkmode = prefs.getBool('darkmode');
    widget.darkMode = darkmode!;
  }

  Future<void> backgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    print(message);
    // const AndroidNotificationChannel channel = AndroidNotificationChannel(
    //   'high_importance_channel', // id
    //   'High Importance Notifications', // title
    //   importance: Importance.max,
    // );
    // flutterLocalNotificationplugin.initialize(
    //   InitializationSettings(
    //       android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    //   onDidReceiveBackgroundNotificationResponse: (details) {
    //     setState(() {
    //       widget.selected = 1;
    //     });
    //   },
    // );
    // flutterLocalNotificationplugin.show(
    //     message.notification.hashCode,
    //     message.notification!.title,
    //     '\u{1F514}' ' ${message.notification!.body}',
    //     NotificationDetails(
    //         android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: message.notification!.body,
    //       color: const Color(0xFF00a651),
    //       importance: Importance.max,
    //       priority: Priority.max,
    //       sound: RawResourceAndroidNotificationSound('notifgpsid'),
    //       groupKey: message.notification!.android!.channelId.toString(),
    //     )));
    // RemoteMessage? initialMessage =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // print(message);

    // FirebaseMessaging.onMessageOpenedApp.listen(
    //   (event) {
    //     print('TAPTAPTAP BACKGROUND');
    //   },
    // );
    // if (message != null) {
    //   handle(message);
    // }
    // if (Platform.isAndroid) {
    //   flutterLocalNotificationplugin.show(
    //       message.hashCode,
    //       message.data['title'],
    //       '\u{1F514}' ' ${message.data['body_id']}',
    //       NotificationDetails(
    //           android: AndroidNotificationDetails(
    //         message.messageId!,
    //         message.data['title'],
    //         channelDescription: message.data['type'],
    //         color: const Color(0xFF00a651),
    //         importance: Importance.max,
    //         priority: Priority.max,
    //         sound: RawResourceAndroidNotificationSound(message.data['sound']),
    //         groupKey: message.messageId,
    //       )));
    // }
  }

  // void handle(RemoteMessage message) {
  //   print(message.data['title']);
  //   if (Platform.isAndroid) {
  //     flutterLocalNotificationplugin.show(
  //         message.hashCode,
  //         message.data['title'],
  //         '\u{1F514}' ' ${message.data['body_id']}',
  //         NotificationDetails(
  //             android: AndroidNotificationDetails(
  //           message.messageId!,
  //           message.data['type'],
  //           channelDescription: message.data['type'],
  //           color: const Color(0xFF00a651),
  //           importance: Importance.max,
  //           priority: Priority.max,
  //           sound: RawResourceAndroidNotificationSound(message.data['sound']),
  //           groupKey: message.messageId,
  //         )));

  //     var intializationSettingsAndroid =
  //         const AndroidInitializationSettings('@mipmap/ic_launcher');
  //     var initializationSettings =
  //         InitializationSettings(android: intializationSettingsAndroid);

  //     flutterLocalNotificationplugin.initialize(
  //       initializationSettings,
  //       onDidReceiveNotificationResponse: (details) {
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => HomePage(
  //                 selected: 1,
  //                 darkMode: widget.darkMode,
  //                 secondAccess: false,
  //               ),
  //             ));
  //       },
  //       onDidReceiveBackgroundNotificationResponse: (details) {
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => HomePage(
  //                 selected: 1,
  //                 darkMode: widget.darkMode,
  //                 secondAccess: false,
  //               ),
  //             ));
  //       },
  //     );
  //   }
  // }

  checkPermission() async {
    var status = await Permission.storage.status;
    var statusLocation = await Permission.location.status;
    var statusNotif = await Permission.notification.status;
    // var location = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (!statusLocation.isGranted) {
      await Permission.location.request();
    }
    if (statusNotif.isDenied) {
      await Permission.notification.request();
    }
    // if (!location.isGranted) {
    //   await Permission.location.request();
    // }
  }

  getPermission() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      sync();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      sync();
    } else {
      print('User declined or has not accepted permission');
      // handleAsync();
    }
  }

  sync() async {
    if (Platform.isAndroid) {
      await initAndroid();
    }
    if (Platform.isIOS) {
      await initializeIOS();
    }
  }

  initAndroid() async {
    await Firebase.initializeApp();
    // FirebaseMessaging.onBackgroundMessage(backgroundMessage);
    // RemoteMessage? initialMessage =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // if (initialMessage != null) {
    //   FirebaseMessaging.onBackgroundMessage(backgroundMessage);
    // }

    // const String channelGroupIdAlarm = 'com.superspring.gpsid.ALARM';
    // const String channelGroupIdInbox = 'com.superspring.gpsid.INBOX';

    // const AndroidNotificationChannelGroup androidNotifChannelGroupAlarm =
    //     AndroidNotificationChannelGroup(
    //   channelGroupIdAlarm,
    //   'channel_group_alarm',
    //   description: 'channel untuk grup notifikasi alarm',
    // );

    // const AndroidNotificationChannelGroup androidNotifChannelGroupInbox =
    //     AndroidNotificationChannelGroup(
    //   channelGroupIdInbox,
    //   'channel_group_inbox',
    //   description: 'channel untuk grup notifikasi inbox',
    // );

    // await flutterLocalNotificationplugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .createNotificationChannelGroup(androidNotifChannelGroupAlarm);

    // await flutterLocalNotificationplugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .createNotificationChannelGroup(androidNotifChannelGroupInbox);

    // const AndroidNotificationChannel('id', 'test');

    // const AndroidNotificationChannel channelAlarm = AndroidNotificationChannel(
    //     'high_importance_channel', // id
    //     'High Importance Notifications', // title
    //     sound: RawResourceAndroidNotificationSound('notifgpsid'),
    //     description:
    //         'This channel is used for alarm notifications.', // description
    //     groupId: channelGroupIdAlarm);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'Notifikasi GPSid', // id
        'GPSid Notification', // title
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notifgpsid'));
    // const AndroidNotificationChannel channelInbox = AndroidNotificationChannel(
    //     'high_importance_channel', // id
    //     'High Importance Notifications', // title
    //     sound: RawResourceAndroidNotificationSound('notifgpsid'),
    //     description:
    //         'This channel is used for inbox notifications.', // description
    //     groupId: channelGroupIdInbox);

    // await flutterLocalNotificationplugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channelAlarm);

    // await flutterLocalNotificationplugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channelInbox);

    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      // setState(() {
      //   selected = 1;
      // });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              selected: 1,
              darkMode: widget.darkMode,
              secondAccess: false,
            ),
          ));
    });

    var intializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: intializationSettingsAndroid);

    flutterLocalNotificationplugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      print(details);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              selected: 1,
              darkMode: widget.darkMode,
              secondAccess: true,
            ),
          ));
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message);
      flutterLocalNotificationplugin.show(
          message.data.hashCode,
          message.data['title'],
          '\u{1F514}' ' ${message.data['body_id']}',
          NotificationDetails(
              android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: message.data['body_id'],
            color: const Color(0xFF00a651),
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notifgpsid'),
            groupKey: message.messageId,
          )));
      if (message.data['type'] == 'command') {
        //
      }
      if (message.data['type'] == 'command') {
        //
      } else {
        //
      }
    });
  }

  initializeIOS() async {
    const String _channelGroupIdAlarm = 'com.superspring.gpsid.ALARM';
    const String _channelGroupIdInbox = 'com.superspring.gpsid.INBOX';
    await Firebase.initializeApp();
    // FirebaseMessaging.onBackgroundMessage(backgroundMessage);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    void onDidReceiveLocalNotification(
        int? id, String? title, String? body, String? payload) async {
      print('test');
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              selected: 1,
              darkMode: widget.darkMode,
              secondAccess: false,
            ),
          ));
    });

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            defaultPresentSound: true,
            requestSoundPermission: true);

    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    flutterLocalNotificationplugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                selected: 1,
                darkMode: widget.darkMode,
                secondAccess: true,
              ),
            ));
      },
    );

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   print(message);
    //   DarwinNotificationDetails notificationDetails =
    //       const DarwinNotificationDetails(
    //           presentSound: true,
    //           threadIdentifier: _channelGroupIdAlarm,
    //           sound: 'notifgpsid');

    //   NotificationDetails notificationDetailsPlatformSpefics =
    //       NotificationDetails(iOS: notificationDetails);

    //   flutterLocalNotificationplugin.show(
    //     message.notification.hashCode,
    //     message.data['title'],
    //     '\u{1F514}' + ' ${message.data['body_en']}',
    //     // '\u{1F600}', untuk icon U+1F600
    //     // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
    //     notificationDetailsPlatformSpefics,
    //   );
    // });
  }

  int idx = 0;
  var imgFile = [];
  var setImage = [];
  late List<ResultsMarker> getResponse;
  late List<IconMarkerUrl> response = [];
  late List<ResultsType> getResponseAssetType;
  late List<IconTypeUrl> responseAssetType = [];
  final controller = GifController();
  bool gettingData = false;
  int allTotal = 0;
  String _storeVersion = '';
  String _localVersion = '';
  int _firebaseResult = 0;

  getReadNotif() async {
    var notif = await GeneralService().readLocalNotifAlarm();
    double height = MediaQuery.of(context).size.height;
    double top = MediaQuery.of(context).viewPadding.top;
    double heightFinal = height - top;

    if (notif is LocalNotifAlarmModel) {
      // showInfoAlert(context, 'sssssttttt ada notif gaes', '');
      setState(() {
        selected = 1;
      });
      await GeneralService().deleteLocalNotifAlarm();
    }
  }

  Future<dynamic> getVersionCheck() async {
    final checkStatus = await APIService().getUpdateCheck();
    final _package = await PackageInfo.fromPlatform();

    if (checkStatus is ErrorTrapModel && _package is ErrorTrapModel) {
      _isError = true;
    } else {
      setState(() {
        _isError = false;
        _storeVersion = checkStatus[0].version;
        _localVersion = _package.version;
        // _storeVersion = '4.1.00'; //Dummy store version
        // _localVersion = '4.0.10'; //Dummy local version
        print('${checkStatus[0].version}');
      });
      String getLocalVers = _localVersion;
      String getStoreVers = _storeVersion;
      if (_storeVersion != '') {
        if (int.parse(getLocalVers.replaceAll('.', '')) <
            int.parse(getStoreVers.replaceAll('.', ''))) {
          print('Local Version < Store Version $getLocalVers | $getStoreVers');
          // showUpdateAlert(
          //     context,
          //     '${_package.appName} v$getStoreVers ${AppLocalizations.of(context)!.isAvailable}',
          //     AppLocalizations.of(context)!.wantUpdate);
          setState(() {
            newUpdate = true;
          });
        }
        if (int.tryParse(getLocalVers.replaceAll('.', '')) ==
            int.tryParse(getStoreVers.replaceAll('.', ''))) {
          print('Local Version = Store Version $getLocalVers | $getStoreVers');
        }
        if (int.parse(getLocalVers.replaceAll('.', '')) >
            int.parse(getStoreVers.replaceAll('.', ''))) {
          print('Local Version > Store Version $getLocalVers | $getStoreVers');
        }
      }
    }
    return checkStatus;
  }

  _download() async {
    // setState(() {
    //   gettingData = false;
    // });
    final List<dynamic> imgName = [];
    final res = [];
    final poiDir = await path_provider.getApplicationDocumentsDirectory();
    // final claraDir = await path_provider.getApplicationDocumentsDirectory();
    String folderName = 'Poi';
    final poiPath = Directory('${poiDir.path}/$folderName');
    // String folderNameClara = 'Clara';
    // final claraPath = Directory('${claraDir.path}/$folderNameClara');

    final result = await APIService().getAsset();

    if (result is AssetMarkerModel) {
      // result.data.results.forEach((el) async {
      //   el.clara.resultClara.forEach((clara) async {
      //     if (await claraPath.exists()) {
      //       print('Clara udah ada');
      //     } else {
      //       claraPath.create();
      //       final res = await http.get(Uri.parse(clara.iconClaraUrl));
      //       final imgName = '${clara.iconClaraId}_${clara.iconClaraName}.png';
      //       final localPath = path.join(claraPath.path, imgName);
      //       final imageFile = File(localPath);
      //       imageFile.writeAsBytes(res.bodyBytes);
      //     }
      //   });
      // });
      result.data.results.forEach((el) async {
        el.poi.resultsPoi.forEach((poi) async {
          if (await poiPath.exists()) {
            print('POI udah ada');
          } else {
            poiPath.create();
            final res = await http.get(Uri.parse(poi.iconPoiUrl));
            final imgName = '${poi.iconPoiId}_${poi.iconPoiName}.png';
            final localPath = path.join(poiPath.path, imgName);
            final imageFile = File(localPath);
            imageFile.writeAsBytes(res.bodyBytes);
          }
        });
      });
      result.data.results.forEach((elAsset) {
        elAsset.marker.resultsMarker.forEach((el1) async {
          final appDirII =
              await path_provider.getApplicationDocumentsDirectory();
          String folderName = el1.iconMarkerId.toString();
          final newPath = Directory('${appDirII.path}/localAsset');
          if (await newPath.exists()) {
            final List<dynamic> imgName = [];
            print('udah ada');
            getResponse = elAsset.marker.resultsMarker;
            getResponse.forEach((el2) {
              if (el2.iconMarkerId == el1.iconMarkerId) {
                response = el2.iconMarkerUrl;
                response.forEach((el3) async {
                  final res = [
                    await http.get(Uri.parse(el3.accOn)),
                    await http.get(Uri.parse(el3.alarm)),
                    await http.get(Uri.parse(el3.lost)),
                    await http.get(Uri.parse(el3.parking))
                  ];
                  imgName.addAll([
                    '${el2.iconMarkerId}_accOn.png',
                    '${el2.iconMarkerId}_alarm.png',
                    '${el2.iconMarkerId}_lost.png',
                    '${el2.iconMarkerId}_parking.png'
                  ]);
                  final localPath = [
                    path.join(newPath.path, imgName[0]),
                    path.join(newPath.path, imgName[1]),
                    path.join(newPath.path, imgName[2]),
                    path.join(newPath.path, imgName[3])
                  ];
                  localPath.forEach((Q) {
                    final imageFile = File(Q);
                    imgFile.addAll([imageFile]);
                  });
                  res.forEach((M) {
                    final img = File(imgFile[idx].path);
                    img.writeAsBytes(M.bodyBytes);
                    setState(() {
                      idx++;
                    });
                  });
                });
              }
            });
          } else {
            newPath.create();
            final List<dynamic> imgName = [];
            print('udah ada');
            getResponse = elAsset.marker.resultsMarker;
            getResponse.forEach((el2) {
              if (el2.iconMarkerId == el1.iconMarkerId) {
                response = el2.iconMarkerUrl;
                response.forEach((el3) async {
                  final res = [
                    await http.get(Uri.parse(el3.accOn)),
                    await http.get(Uri.parse(el3.alarm)),
                    await http.get(Uri.parse(el3.lost)),
                    await http.get(Uri.parse(el3.parking))
                  ];
                  imgName.addAll([
                    '${el2.iconMarkerId}_accOn.png',
                    '${el2.iconMarkerId}_alarm.png',
                    '${el2.iconMarkerId}_lost.png',
                    '${el2.iconMarkerId}_parking.png'
                  ]);
                  final localPath = [
                    path.join(newPath.path, imgName[0]),
                    path.join(newPath.path, imgName[1]),
                    path.join(newPath.path, imgName[2]),
                    path.join(newPath.path, imgName[3])
                  ];
                  localPath.forEach((Q) {
                    final imageFile = File(Q);
                    imgFile.addAll([imageFile]);
                  });
                  res.forEach((M) {
                    final img = File(imgFile[idx].path);
                    img.writeAsBytes(M.bodyBytes);
                    setState(() {
                      idx++;
                    });
                  });
                });
              }
            });
          }
        });
      });
      result.data.results.forEach((elType) {
        elType.type.resultsType.forEach((el4) async {
          final appDirIII =
              await path_provider.getApplicationDocumentsDirectory();
          String folderName = el4.iconTypeId.toString();
          final newPath = Directory('${appDirIII.path}/localAssetType');
          if (await newPath.exists()) {
            final List<dynamic> imgName = [];
            print('udah ada');
            getResponseAssetType = elType.type.resultsType;
            getResponseAssetType.forEach((el5) {
              if (el5.iconTypeId == el4.iconTypeId) {
                responseAssetType = el5.iconTypeUrl;
                responseAssetType.forEach((el6) async {
                  final res = [
                    await http.get(Uri.parse(el6.accOn)),
                    await http.get(Uri.parse(el6.alarm)),
                    await http.get(Uri.parse(el6.lost)),
                    await http.get(Uri.parse(el6.parking))
                  ];
                  imgName.addAll([
                    '${el5.iconTypeName.toLowerCase()}_accOn.png',
                    '${el5.iconTypeName.toLowerCase()}_alarm.png',
                    '${el5.iconTypeName.toLowerCase()}_lost.png',
                    '${el5.iconTypeName.toLowerCase()}_parking.png'
                  ]);
                  final localPath = [
                    path.join(newPath.path, imgName[0]),
                    path.join(newPath.path, imgName[1]),
                    path.join(newPath.path, imgName[2]),
                    path.join(newPath.path, imgName[3])
                  ];
                  localPath.forEach((Q) {
                    final imageFile = File(Q);
                    imgFile.addAll([imageFile]);
                  });
                  res.forEach((M) {
                    final img = File(imgFile[idx].path);
                    img.writeAsBytes(M.bodyBytes);
                    setState(() {
                      idx++;
                    });
                  });
                });
              }
            });
          } else {
            newPath.create();
            final List<dynamic> imgName = [];
            print('udah ada');
            getResponseAssetType = elType.type.resultsType;
            getResponseAssetType.forEach((el5) {
              if (el5.iconTypeId == el4.iconTypeId) {
                responseAssetType = el5.iconTypeUrl;
                responseAssetType.forEach((el6) async {
                  final res = [
                    await http.get(Uri.parse(el6.accOn)),
                    await http.get(Uri.parse(el6.alarm)),
                    await http.get(Uri.parse(el6.lost)),
                    await http.get(Uri.parse(el6.parking))
                  ];
                  imgName.addAll([
                    '${el5.iconTypeName.toLowerCase()}_accOn.png',
                    '${el5.iconTypeName.toLowerCase()}_alarm.png',
                    '${el5.iconTypeName.toLowerCase()}_lost.png',
                    '${el5.iconTypeName.toLowerCase()}_parking.png'
                  ]);
                  final localPath = [
                    path.join(newPath.path, imgName[0]),
                    path.join(newPath.path, imgName[1]),
                    path.join(newPath.path, imgName[2]),
                    path.join(newPath.path, imgName[3])
                  ];
                  localPath.forEach((Q) {
                    final imageFile = File(Q);
                    imgFile.addAll([imageFile]);
                  });
                  res.forEach((M) {
                    final img = File(imgFile[idx].path);
                    img.writeAsBytes(M.bodyBytes);
                    setState(() {
                      idx++;
                    });
                  });
                });
              }
            });
          }
        });
      });
      // setState(() {
      //   gettingData = true;
      // });
    } else {
      print(result);
      // setState(() {
      //   gettingData = true;
      // });
    }
    if (data.Username == 'demo') {
      setState(() {
        gettingData = true;
      });
    } else {
      if (widget.secondAccess) {
        setState(() {
          gettingData = true;
        });
      } else {
        initClara();
      }
      // widget.secondAccess ? {} : initClara();
      print(widget.secondAccess);
    }
    // data.Username == 'demo' ? {} : initClara();
  }

  Future<dynamic> getLocal() async {
    data = await GeneralService().readLocalUserStorage();
    url = await GeneralService().readLocalUrl();
    return data;
  }

  Future<dynamic> getPoin() async {
    setState(() {
      sspoinLoading = true;
    });
    LocalData data = await GeneralService().readLocalUserStorage();
    final result = await APIService().getCurrentPoin();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853SSpoin';
        _errorMessage = result;
        sspoinLoading = false;
        // initPlatformState();
      });
    } else {
      // _download();
      setState(() {
        _isError = false;
        _errCode = '';
        sspoinLoading = false;
      });
    }
    return data.SeenId != 0 ? result : false;
  }

  Future<dynamic> getBanner() async {
    setState(() {
      bannerLoading = true;
    });
    // await _download();
    final result = await APIService().getBanner();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853banner';
        _errorMessage = result;
        bannerLoading = false;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        bannerLoading = false;
      });
    }
    return result;
  }

  Future<dynamic> getProduct() async {
    final result = await APIService().getProduct();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853product';
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

  Future<dynamic> getMoving() async {
    await _download();
    setState(() {
      movingLoading = true;
    });
    final result = await APIService().getMoving();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853moving';
        _errorMessage = result;
        movingLoading = false;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        movingLoading = false;
        allTotal = allTotal + int.parse(result.data.unit.toString());
      });
    }
    return result;
  }

  Future<dynamic> getPark() async {
    setState(() {
      parkLoading = true;
    });
    final result = await APIService().getPark();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853park';
        _errorMessage = result;
        parkLoading = false;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        parkLoading = false;
        allTotal = allTotal + int.parse(result.data.unit.toString());
      });
    }
    return result;
  }

  Future<dynamic> getStop() async {
    setState(() {
      stopLoading = true;
    });
    final result = await APIService().getStop();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853stop';
        _errorMessage = result;
        stopLoading = false;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        stopLoading = false;
        allTotal = allTotal + int.parse(result.data.unit.toString());
      });
    }
    return result;
  }

  Future<dynamic> getNoData() async {
    setState(() {
      lostLoading = true;
    });
    final result = await APIService().getNoData();
    if (result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        _errCode = '76853moving';
        _errorMessage = result;
        lostLoading = false;
        // initPlatformState();
      });
    } else {
      setState(() {
        _isError = false;
        _errCode = '';
        lostLoading = false;
        allTotal = allTotal + int.parse(result.data.unit.toString());
      });
    }
    return result;
  }

  readLocal() async {
    // await GeneralService().readLocalUserStorage();
    // LocalData _localdata = await GeneralService().readLocalUserStorage();
    // print(_localdata);
    await GeneralService().deleteLocalUserStorage();
  }

  Future<bool> _onWillPop() {
    print('SELECTED: $selected');
    if (selected != 0) {
      setState(() {
        selected = 0;
      });
    } else {
      pressCount++;
      if (pressCount == 2) {
        exit(0);
        // if (Platform.isAndroid) {
        //   exit(0);
        // } else if (Platform.isIOS) {
        //   exit(0);
        // }
        // return Future.value(true);
      }
      var snackBar = SnackBar(content: Text('press again to exit from app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return Future.value(false);
    }
    return Future.value(false);
  }

  Future<bool> _onWillPopDialog() {
    print('SELECTED: $selected');
    // if (selected != 0) {
    //   setState(() {
    //     selected = 0;
    //   });
    // } else {
    //   pressCount++;
    //   if (pressCount == 2) {
    //     exit(0);
    //     // if (Platform.isAndroid) {
    //     //   exit(0);
    //     // } else if (Platform.isIOS) {
    //     //   exit(0);
    //     // }
    //     // return Future.value(true);
    //   }
    //   var snackBar = SnackBar(content: Text('press again to exit from app'));
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   return Future.value(false);
    // }
    if (selected != 0) {
      setState(() {
        selected = 0;
      });
    } else {
      pressCount++;
      if (pressCount == 2) {
        exit(0);
        // if (Platform.isAndroid) {
        //   exit(0);
        // } else if (Platform.isIOS) {
        //   exit(0);
        // }
        // return Future.value(true);
      }
      var snackBar = SnackBar(content: Text('press again to exit from app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return Future.value(false);
    }
    return Future.value(false);
    // return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    Padding progressComplete = Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Container(
        // width: width / 7,
        height: 8,
        decoration: BoxDecoration(
          color: yellowPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );

    Padding progressIncomplete = Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Container(
        // width: width / 7,
        height: 8,
        decoration: BoxDecoration(
          color: whiteColorDarkMode,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: IndexedStack(
          index: selected,
          children: [
            RefreshIndicator(
                onRefresh: () async {
                  // await _download();
                  setState(() {
                    progressCount = 0;
                  });
                  allTotal = 0;
                  _getBanner = getBanner();
                  _getProduct = getProduct();
                  _getMoving = getMoving();
                  _getPark = getPark();
                  _getStop = getStop();
                  _getNoData = getNoData();
                  _getLocal = getLocal();
                  _getPoin = getPoin();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 210,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 210,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        widget.darkMode
                                            ? 'assets/bggradientdarkmode.png'
                                            : 'assets/bggradient.png',
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 60,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FutureBuilder(
                                                future: _getLocal,
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<dynamic>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    data = snapshot.data;
                                                    return Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                InkWell(
                                                                  child: Text(
                                                                    '${greeting()},',
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : whiteColor,
                                                                    ),
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    // initClara();
                                                                    // SystemChrome
                                                                    //     .setPreferredOrientations([
                                                                    //   DeviceOrientation
                                                                    //       .landscapeLeft,
                                                                    //   DeviceOrientation
                                                                    //       .landscapeRight
                                                                    // ]);
                                                                  },
                                                                ),
                                                                AutoSizeText(
                                                                    data.Fullname ==
                                                                            ''
                                                                        ? data
                                                                            .Username
                                                                        : data
                                                                            .Fullname,
                                                                    maxLines: 2,
                                                                    minFontSize:
                                                                        14,
                                                                    maxFontSize:
                                                                        16,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: bold
                                                                        .copyWith(
                                                                      // fontSize: 16,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : whiteColor,
                                                                    )),
                                                                // Text(
                                                                //   data.Fullname == ''
                                                                //       ? data
                                                                //           .Username
                                                                //       : data
                                                                //           .Fullname,
                                                                //   style:
                                                                //       bold.copyWith(
                                                                //     fontSize: 16,
                                                                //     color:
                                                                //         whiteColor,
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              GestureDetector(
                                                                child:
                                                                    Image.asset(
                                                                  'assets/whatsapp.png',
                                                                  width: 100,
                                                                ),
                                                                onTap: () {
                                                                  showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    isDismissible:
                                                                        true,
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              12),
                                                                          topRight:
                                                                              Radius.circular(12)),
                                                                    ),
                                                                    backgroundColor:
                                                                        whiteCardColor,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
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
                                                                                Stack(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(AppLocalizations.of(context)!.needHelp, style: bold.copyWith(fontSize: 16, color: blackPrimary)),
                                                                                      ],
                                                                                    ),
                                                                                    InkWell(
                                                                                      onTap: () {},
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.close,
                                                                                              size: 30,
                                                                                              color: blackPrimary,
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
                                                                                      AppLocalizations.of(context)!.needHelpSub,
                                                                                      style: reguler.copyWith(fontSize: 10, color: blackSecondary3),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                  ],
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
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                                        child: Image.asset('assets/wa2.png', width: 18, height: 18, color: widget.darkMode ? null : greyColor),
                                                                                                      ),
                                                                                                      Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
                                                                                                    ],
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
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                                        child: Image.asset(
                                                                                                          'assets/wa2.png',
                                                                                                          width: 18,
                                                                                                          height: 18,
                                                                                                        ),
                                                                                                      ),
                                                                                                      Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
                                                                                                    ],
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return Text(
                                                    '${AppLocalizations.of(context)!.gettingLocalData}...',
                                                    style: bold.copyWith(
                                                      fontSize: 20,
                                                      color:
                                                          blueGradientSecondary1,
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 120, bottom: 24),
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/searchvehicle'),
                                  child: Image.asset(widget.darkMode
                                      ? AppLocalizations.of(context)!
                                          .searchHomeDark
                                      : AppLocalizations.of(context)!
                                          .searchHome),
                                ),
                                Visibility(
                                    visible: imeiDemo == '123456' ||
                                            data.Username == 'demo'
                                        ? false
                                        : true,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: InkWell(
                                        // onTap: () => Navigator.pushNamed(
                                        //     context, '/sspoin'),
                                        onTap: () async {
                                          if (!disableSSpoin) {
                                            if (!ssPoin.data.isBlock) {
                                              await Navigator.pushNamed(
                                                  context, '/sspoin');
                                              _getPoin = getPoin();
                                            }
                                          }
                                          // !disableSSpoin
                                          //     ? ssPoin.data.isBlock
                                          //         ? {}
                                          //         : Navigator.pushNamed(
                                          //             context, '/sspoin')
                                          //     : {};
                                        },
                                        child: Visibility(
                                            visible: !ssPoin.data.isBlock,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/sspoint.png',
                                                      width: 24,
                                                    ),
                                                    const SizedBox(
                                                      width: 9,
                                                    ),
                                                    FutureBuilder(
                                                      future: _getPoin,
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                        if (snapshot.hasData &&
                                                            !sspoinLoading) {
                                                          if (snapshot.data
                                                              is ErrorTrapModel) {
                                                            return InkWell(
                                                              onTap: () {
                                                                // refreshPoin();
                                                                _getPoin =
                                                                    getPoin();
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Refresh',
                                                                    style: reguler
                                                                        .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: widget
                                                                              .darkMode
                                                                          ? whiteColorDarkMode
                                                                          : whiteColor,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .refresh_rounded,
                                                                    size: 15,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : whiteColor,
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            if (snapshot.data ==
                                                                false) {
                                                              // setState(() {
                                                              //   disableSSpoin = true;
                                                              // });
                                                              disableSSpoin =
                                                                  true;
                                                              return Text(
                                                                'NOT AVAILABLE',
                                                                style: reguler
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color: widget
                                                                          .darkMode
                                                                      ? whiteColorDarkMode
                                                                      : whiteColor,
                                                                ),
                                                              );
                                                            } else {
                                                              if (snapshot.data
                                                                  is MessageModel) {
                                                                disableSSpoin =
                                                                    true;
                                                                return InkWell(
                                                                  onTap: () {
                                                                    // refreshPoin();
                                                                    _getPoin =
                                                                        getPoin();
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        'Refresh',
                                                                        style: reguler
                                                                            .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color: widget.darkMode
                                                                              ? whiteColorDarkMode
                                                                              : whiteColor,
                                                                        ),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .refresh_rounded,
                                                                        size:
                                                                            15,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColor,
                                                                      )
                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                ssPoin =
                                                                    snapshot
                                                                        .data;
                                                                return Visibility(
                                                                    visible: !ssPoin
                                                                        .data
                                                                        .isBlock,
                                                                    child: Text(
                                                                      '${ssPoin.data.currentPoint} SSPoin',
                                                                      style: reguler
                                                                          .copyWith(
                                                                        fontSize:
                                                                            14,
                                                                        color: widget.darkMode
                                                                            ? whiteColorDarkMode
                                                                            : whiteColor,
                                                                      ),
                                                                    ));
                                                              }
                                                            }
                                                          }
                                                        }
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            right: 12,
                                                          ),
                                                          width: 90,
                                                          height: 22,
                                                          child: SkeletonTheme(
                                                            themeMode: widget
                                                                    .darkMode
                                                                ? ThemeMode.dark
                                                                : ThemeMode
                                                                    .light,
                                                            child:
                                                                SkeletonAvatar(
                                                              style: SkeletonAvatarStyle(
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  width: 140,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  height: 30),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: widget.darkMode
                                                      ? whiteColorDarkMode
                                                      : whiteColor,
                                                  size: 20,
                                                )
                                              ],
                                            )),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //BANNER BARU
                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (Platform.isAndroid) {
                                          launchUrl(
                                              Uri.parse(
                                                  'https://play.google.com/store/apps/details?id=com.superspring.gpsid'),
                                              mode: LaunchMode
                                                  .externalNonBrowserApplication);
                                          // launch(
                                          //     'https://play.google.com/store/apps/details?id=com.superspring.gpsid');
                                        }
                                        if (Platform.isIOS) {
                                          launchUrl(
                                              Uri.parse(
                                                  'https://apps.apple.com/id/app/gps-id-dari-super-spring/id1119572414?uo=4'),
                                              mode: LaunchMode
                                                  .externalNonBrowserApplication);
                                          // launch(
                                          //     'https://apps.apple.com/id/app/gps-id-dari-super-spring/id1119572414?uo=4');
                                        }
                                      },
                                      child: Visibility(
                                        visible: newUpdate,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 32,
                                            left: 16,
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.2,
                                            height: 120,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                gradient: SweepGradient(
                                                    startAngle: 5.0,
                                                    endAngle: 5.8,
                                                    stops: const [
                                                      1.2,
                                                      2.5,
                                                      3.1
                                                    ],
                                                    center:
                                                        Alignment.bottomLeft,
                                                    transform:
                                                        GradientRotation(-0.4),
                                                    colors: const [
                                                      Color(0xFFF4882A),
                                                      Color(0xFFFFC717),
                                                      Color.fromARGB(
                                                          255, 255, 155, 41),
                                                    ])),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 25,
                                                      horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: Text(
                                                      'GPS.id $_storeVersion ${AppLocalizations.of(context)!.isAvailable}',
                                                      style: bold.copyWith(
                                                          color:
                                                              whiteColorDarkMode,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .wantUpdate,
                                                      style: reguler.copyWith(
                                                          color:
                                                              whiteColorDarkMode,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Navigator.pushNamed(
                                    //         context, '/editprofile');
                                    //   },
                                    //   child: Visibility(
                                    //     visible: data.Privilage != 4
                                    //         ? false
                                    //         : !emailVerif,
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.only(
                                    //           bottom: 32, left: 16),
                                    //       child: Container(
                                    //         width: MediaQuery.of(context)
                                    //                 .size
                                    //                 .width /
                                    //             1.2,
                                    //         height: 110,
                                    //         decoration: BoxDecoration(
                                    //             borderRadius:
                                    //                 const BorderRadius.all(
                                    //                     Radius.circular(8)),
                                    //             gradient: SweepGradient(
                                    //                 startAngle: 5.0,
                                    //                 endAngle: 5.8,
                                    //                 stops: const [
                                    //                   1.2,
                                    //                   2.5,
                                    //                   3.1
                                    //                 ],
                                    //                 center:
                                    //                     Alignment.bottomLeft,
                                    //                 transform:
                                    //                     GradientRotation(-0.4),
                                    //                 colors: const [
                                    //                   Color(0xFFF4882A),
                                    //                   Color(0xFFFFC717),
                                    //                   Color.fromARGB(
                                    //                       255, 255, 155, 41),
                                    //                 ])),
                                    //         child: Padding(
                                    //           padding:
                                    //               const EdgeInsets.symmetric(
                                    //                   vertical: 25,
                                    //                   horizontal: 15),
                                    //           child: Column(
                                    //             crossAxisAlignment:
                                    //                 CrossAxisAlignment.start,
                                    //             children: [
                                    //               Padding(
                                    //                 padding: const EdgeInsets
                                    //                     .symmetric(vertical: 2),
                                    //                 child: Text(
                                    //                   AppLocalizations.of(
                                    //                           context)!
                                    //                       .verifEmail,
                                    //                   style: bold.copyWith(
                                    //                       color:
                                    //                           whiteColorDarkMode,
                                    //                       fontSize: 12),
                                    //                 ),
                                    //               ),
                                    //               Padding(
                                    //                 padding: const EdgeInsets
                                    //                     .symmetric(vertical: 2),
                                    //                 child: Text(
                                    //                   AppLocalizations.of(
                                    //                           context)!
                                    //                       .verifEmailSub,
                                    //                   style: reguler.copyWith(
                                    //                       color:
                                    //                           whiteColorDarkMode,
                                    //                       fontSize: 10),
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/editprofile');
                                      },
                                      child: Visibility(
                                        visible: data.Privilage != 4
                                            ? false
                                            : completeProfile,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 32, left: 16),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.2,
                                            height: 120,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                gradient: SweepGradient(
                                                    startAngle: 5.0,
                                                    endAngle: 5.8,
                                                    stops: const [
                                                      1.2,
                                                      2.5,
                                                      3.1
                                                    ],
                                                    center:
                                                        Alignment.bottomLeft,
                                                    transform:
                                                        GradientRotation(-0.4),
                                                    colors: const [
                                                      Color(0xFFF4882A),
                                                      Color(0xFFFFC717),
                                                      Color.fromARGB(
                                                          255, 255, 155, 41),
                                                    ])),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 25,
                                                      horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .completeProfile,
                                                      style: bold.copyWith(
                                                          color:
                                                              whiteColorDarkMode,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 2),
                                                      child: progressCount == 1
                                                          ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        progressComplete),
                                                                Expanded(
                                                                    child:
                                                                        progressIncomplete),
                                                                Expanded(
                                                                    child:
                                                                        progressIncomplete),
                                                                Expanded(
                                                                    child:
                                                                        progressIncomplete),
                                                                Expanded(
                                                                    child:
                                                                        progressIncomplete)
                                                              ],
                                                            )
                                                          : progressCount == 2
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            progressComplete),
                                                                    Expanded(
                                                                        child:
                                                                            progressComplete),
                                                                    Expanded(
                                                                        child:
                                                                            progressIncomplete),
                                                                    Expanded(
                                                                        child:
                                                                            progressIncomplete),
                                                                    Expanded(
                                                                        child:
                                                                            progressIncomplete)
                                                                  ],
                                                                )
                                                              : progressCount ==
                                                                      3
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                progressComplete),
                                                                        Expanded(
                                                                            child:
                                                                                progressComplete),
                                                                        Expanded(
                                                                            child:
                                                                                progressComplete),
                                                                        Expanded(
                                                                            child:
                                                                                progressIncomplete),
                                                                        Expanded(
                                                                            child:
                                                                                progressIncomplete)
                                                                      ],
                                                                    )
                                                                  : progressCount ==
                                                                          4
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Expanded(child: progressComplete),
                                                                            Expanded(child: progressComplete),
                                                                            Expanded(child: progressComplete),
                                                                            Expanded(child: progressComplete),
                                                                            Expanded(child: progressIncomplete)
                                                                          ],
                                                                        )
                                                                      : progressCount ==
                                                                              0
                                                                          ? Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(child: progressIncomplete),
                                                                                Expanded(child: progressIncomplete),
                                                                                Expanded(child: progressIncomplete),
                                                                                Expanded(child: progressIncomplete),
                                                                                Expanded(child: progressIncomplete)
                                                                              ],
                                                                            )
                                                                          : Container()),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 2),
                                                      child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                            TextSpan(
                                                              text:
                                                                  '${AppLocalizations.of(context)!.done} ',
                                                              style: reguler
                                                                  .copyWith(
                                                                      color:
                                                                          whiteColorDarkMode,
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '$progressCount ${AppLocalizations.of(context)!.ofs} 5. ',
                                                              style: reguler
                                                                  .copyWith(
                                                                      color:
                                                                          whiteColorDarkMode,
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${AppLocalizations.of(context)!.completeProfileSub} ',
                                                              style: reguler
                                                                  .copyWith(
                                                                      color:
                                                                          whiteColorDarkMode,
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                            TextSpan(
                                                              text: AppLocalizations
                                                                      .of(context)!
                                                                  .updateProfile,
                                                              style: bold.copyWith(
                                                                  color:
                                                                      whiteColorDarkMode,
                                                                  fontSize: 10,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      whiteColorDarkMode),
                                                            )
                                                          ]))),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .unitStatus,
                                          style: bold.copyWith(
                                              fontSize: 14,
                                              color: blackPrimary),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  gettingData
                                      ? SizedBox(
                                          width: double.infinity,
                                          height: 84,
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            padding: EdgeInsets.only(
                                                right: 16, left: 16),
                                            scrollDirection: Axis.horizontal,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // Navigator.pushNamed(
                                                  //     context, '/vehiclelist');
                                                },
                                                child: StatusUnitCard(
                                                  StatusUnit(
                                                    mobil:
                                                        'assets/vehicle/car_moving.png',
                                                    status: AppLocalizations.of(
                                                            context)!
                                                        .all,
                                                    jumlah: allTotal.toString(),
                                                    warna: blackSecondary3,
                                                  ),
                                                  all: true,
                                                  darkmode: widget.darkMode,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              FutureBuilder(
                                                  future: _getMoving,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                    if (snapshot.hasData &&
                                                        !movingLoading) {
                                                      if (snapshot.data
                                                          is ErrorTrapModel) {
                                                        //SKELETON
                                                        return SizedBox(
                                                          width: 135,
                                                          height: 84,
                                                          child: SkeletonTheme(
                                                            themeMode: widget
                                                                    .darkMode
                                                                ? ThemeMode.dark
                                                                : ThemeMode
                                                                    .light,
                                                            child:
                                                                SkeletonAvatar(
                                                              style:
                                                                  SkeletonAvatarStyle(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 32,
                                                                // height: 120
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        VehicleStatusModel
                                                            moving =
                                                            snapshot.data;
                                                        return InkWell(
                                                          onTap: () {
                                                            // Navigator.pushNamed(
                                                            //     context, '/vehiclelist');
                                                          },
                                                          child: StatusUnitCard(
                                                            StatusUnit(
                                                              mobil:
                                                                  'assets/vehicle/car_moving.png',
                                                              status:
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .moving,
                                                              jumlah: moving
                                                                  .data.unit
                                                                  .toString(),
                                                              warna:
                                                                  bluePrimary,
                                                            ),
                                                            all: false,
                                                            darkmode:
                                                                widget.darkMode,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    //SKELETON
                                                    return SizedBox(
                                                      width: 135,
                                                      height: 84,
                                                      child: SkeletonTheme(
                                                        themeMode: widget
                                                                .darkMode
                                                            ? ThemeMode.dark
                                                            : ThemeMode.light,
                                                        child: SkeletonAvatar(
                                                          style:
                                                              SkeletonAvatarStyle(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            width: 32,
                                                            // height: 120
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              FutureBuilder(
                                                  future: _getPark,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                    if (snapshot.hasData &&
                                                        !parkLoading) {
                                                      if (snapshot.data
                                                          is ErrorTrapModel) {
                                                        //SKELETON
                                                        return SizedBox(
                                                          width: 135,
                                                          height: 84,
                                                          child: SkeletonTheme(
                                                            themeMode: widget
                                                                    .darkMode
                                                                ? ThemeMode.dark
                                                                : ThemeMode
                                                                    .light,
                                                            child:
                                                                SkeletonAvatar(
                                                              style:
                                                                  SkeletonAvatarStyle(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 32,
                                                                // height: 120
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        VehicleStatusModel
                                                            park =
                                                            snapshot.data;
                                                        return InkWell(
                                                          onTap: () {
                                                            // Navigator.pushNamed(
                                                            //     context, '/vehiclelist');
                                                          },
                                                          child: StatusUnitCard(
                                                            StatusUnit(
                                                              mobil:
                                                                  'assets/vehicle/car_stop.png',
                                                              status:
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .park,
                                                              jumlah: park
                                                                  .data.unit
                                                                  .toString(),
                                                              warna:
                                                                  blackPrimary,
                                                            ),
                                                            all: false,
                                                            darkmode:
                                                                widget.darkMode,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    //SKELETON
                                                    return SizedBox(
                                                      width: 135,
                                                      height: 84,
                                                      child: SkeletonTheme(
                                                        themeMode: widget
                                                                .darkMode
                                                            ? ThemeMode.dark
                                                            : ThemeMode.light,
                                                        child: SkeletonAvatar(
                                                          style:
                                                              SkeletonAvatarStyle(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            width: 32,
                                                            // height: 120
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              FutureBuilder(
                                                  future: _getStop,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                    if (snapshot.hasData &&
                                                        !stopLoading) {
                                                      if (snapshot.data
                                                          is ErrorTrapModel) {
                                                        //SKELETON
                                                        return SizedBox(
                                                          width: 135,
                                                          height: 84,
                                                          child: SkeletonTheme(
                                                            themeMode: widget
                                                                    .darkMode
                                                                ? ThemeMode.dark
                                                                : ThemeMode
                                                                    .light,
                                                            child:
                                                                SkeletonAvatar(
                                                              style:
                                                                  SkeletonAvatarStyle(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 32,
                                                                // height: 120
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        VehicleStatusModel
                                                            stop =
                                                            snapshot.data;

                                                        return InkWell(
                                                          onTap: () {
                                                            // Navigator.pushNamed(
                                                            //     context, '/vehiclelist');
                                                          },
                                                          child: StatusUnitCard(
                                                            StatusUnit(
                                                                mobil:
                                                                    'assets/vehicle/car_stop.png',
                                                                status: AppLocalizations.of(
                                                                        context)!
                                                                    .stop,
                                                                jumlah: stop
                                                                    .data.unit
                                                                    .toString(),
                                                                warna:
                                                                    blackPrimary),
                                                            all: false,
                                                            darkmode:
                                                                widget.darkMode,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    //SKELETON
                                                    return SizedBox(
                                                      width: 135,
                                                      height: 84,
                                                      child: SkeletonTheme(
                                                        themeMode: widget
                                                                .darkMode
                                                            ? ThemeMode.dark
                                                            : ThemeMode.light,
                                                        child: SkeletonAvatar(
                                                          style:
                                                              SkeletonAvatarStyle(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            width: 32,
                                                            // height: 120
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              // ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              // StatusUnitCard(
                                              //   StatusUnit(
                                              //       mobil: 'assets/mobil_nodata.png',
                                              //       status: AppLocalizations.of(context)!.noData,
                                              //       jumlah: '7',
                                              //       warna: bluePrimary),
                                              // ),
                                              FutureBuilder(
                                                  future: _getNoData,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                    if (snapshot.hasData &&
                                                        !lostLoading) {
                                                      if (snapshot.data
                                                          is ErrorTrapModel) {
                                                        //SKELETON
                                                        return SizedBox(
                                                          width: 135,
                                                          height: 84,
                                                          child: SkeletonTheme(
                                                            themeMode: widget
                                                                    .darkMode
                                                                ? ThemeMode.dark
                                                                : ThemeMode
                                                                    .light,
                                                            child:
                                                                SkeletonAvatar(
                                                              style:
                                                                  SkeletonAvatarStyle(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                width: 32,
                                                                // height: 120
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        VehicleStatusModel
                                                            noData =
                                                            snapshot.data;

                                                        return InkWell(
                                                          onTap: () {
                                                            // Navigator.pushNamed(
                                                            //     context, '/vehiclelist');
                                                          },
                                                          child: StatusUnitCard(
                                                            StatusUnit(
                                                                mobil:
                                                                    'assets/vehicle/car_lost.png',
                                                                status: AppLocalizations.of(
                                                                        context)!
                                                                    .lost,
                                                                jumlah: noData
                                                                    .data.unit
                                                                    .toString(),
                                                                warna:
                                                                    yellowPrimary),
                                                            all: false,
                                                            darkmode:
                                                                widget.darkMode,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    //SKELETON
                                                    return SizedBox(
                                                      width: 135,
                                                      height: 84,
                                                      child: SkeletonTheme(
                                                        themeMode: widget
                                                                .darkMode
                                                            ? ThemeMode.dark
                                                            : ThemeMode.light,
                                                        child: SkeletonAvatar(
                                                          style:
                                                              SkeletonAvatarStyle(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            width: 32,
                                                            // height: 120
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          // width: 135,
                                          height: 84,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: SkeletonTheme(
                                              themeMode: widget.darkMode
                                                  ? ThemeMode.dark
                                                  : ThemeMode.light,
                                              child: SkeletonAvatar(
                                                style: SkeletonAvatarStyle(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    shape: BoxShape.rectangle,
                                                    width: double.infinity,
                                                    height: 84),
                                              ),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.fyi,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .thankYouForTrustingUs,
                                        style: reguler.copyWith(
                                          fontSize: 10,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -14),
                                  child: FutureBuilder(
                                      future: _getBanner,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.hasData &&
                                            !bannerLoading) {
                                          if (snapshot.data is ErrorTrapModel) {
                                            //SKELETON
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 30,
                                                  left: 10,
                                                  right: 10),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 160,
                                                child: SkeletonTheme(
                                                  themeMode: widget.darkMode
                                                      ? ThemeMode.dark
                                                      : ThemeMode.light,
                                                  child: SkeletonAvatar(
                                                    style: SkeletonAvatarStyle(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      shape: BoxShape.rectangle,
                                                      width: 32,
                                                      // height: 120
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            List<Result> banners =
                                                snapshot.data;
                                            return CarouselSlider.builder(
                                                // itemCount: 5,
                                                itemCount: banners.length,
                                                itemBuilder: (context, index,
                                                    realIndex) {
                                                  return InkWell(
                                                    onTap: () {
                                                      banners[index]
                                                              .Url_link
                                                              .isNotEmpty
                                                          ? launchUrl(
                                                              Uri.parse(banners[
                                                                      index]
                                                                  .Url_link),
                                                              mode: LaunchMode
                                                                  .externalApplication)
                                                          : {};
                                                      // print(
                                                      //     'Banner tap: ${banners[index].Name}');
                                                      // launchUrl(
                                                      //     Uri.parse(banners[
                                                      //             index]
                                                      //         .FileMobile),
                                                      //     mode: LaunchMode
                                                      //         .externalApplication);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16),
                                                      child: Image.network(
                                                        banners[index]
                                                            .FileMobile,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                options: CarouselOptions(
                                                    autoPlay: true,
                                                    // enlargeCenterPage:
                                                    //     true,
                                                    // aspectRatio: 16 / 9,
                                                    padEnds: false,
                                                    // viewportFraction: 0.77,
                                                    enableInfiniteScroll:
                                                        false));
                                          }
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 30, left: 10, right: 10),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 160,
                                            child: SkeletonTheme(
                                              themeMode: widget.darkMode
                                                  ? ThemeMode.dark
                                                  : ThemeMode.light,
                                              child: SkeletonAvatar(
                                                style: SkeletonAvatarStyle(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  width: 32,
                                                  // height: 120
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                // const SizedBox(
                                //   height: 30,
                                // ),
                              ],
                            ),
                            Transform.translate(
                              offset: Offset(0, -10),
                              child: Visibility(
                                visible: data.Username == 'demo' ||
                                        imeiDemo == '123456'
                                    ? false
                                    : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .checkSubscription,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: InkWell(
                                            onTap: () => Navigator.pushNamed(
                                                context, '/expiredvehiclelist'),
                                            child: Image.asset(
                                                AppLocalizations.of(context)!
                                                    .checkSubsImg),
                                          )),
                                      const SizedBox(
                                        height: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .ourProduct,
                                        style: bold.copyWith(
                                          fontSize: 14,
                                          color: blackPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(
                                          context, '/productlist'),
                                      child: Image.asset(
                                          AppLocalizations.of(context)!
                                              .product),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            selected == 1
                ? NotificationPage(
                    fromNotif: false,
                    id: 0,
                    darkMode: widget.darkMode,
                  )
                : const Center(),
            // const Tracking(),
            // const LandingCart(),
            const Center(),
            selected == 3
                ? LandingCart(
                    darkMode: widget.darkMode,
                  )
                : const Center(),
            OtherPage(
              darkMode: widget.darkMode,
              progressCount: progressCount,
              completeProfile: completeProfile,
            ),
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
        //                       allTotal = 0;
        //                       _getBanner = getBanner();
        //                       _getProduct = getProduct();
        //                       _getMoving = getMoving();
        //                       _getPark = getPark();
        //                       _getStop = getStop();
        //                       _getNoData = getNoData();
        //                       _getLocal = getLocal();
        //                       _getPoin = getPoin();
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
        //     : IndexedStack(
        //         index: selected,
        //         children: [
        //           RefreshIndicator(
        //               onRefresh: () async {
        //                 // await _download();
        //                 allTotal = 0;
        //                 _getBanner = getBanner();
        //                 _getProduct = getProduct();
        //                 _getMoving = getMoving();
        //                 _getPark = getPark();
        //                 _getStop = getStop();
        //                 _getNoData = getNoData();
        //                 _getLocal = getLocal();
        //                 _getPoin = getPoin();
        //               },
        //               child: SingleChildScrollView(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Stack(
        //                       children: [
        //                         SizedBox(
        //                           height: 210,
        //                           width: double.infinity,
        //                           child: Stack(
        //                             children: [
        //                               SizedBox(
        //                                 height: 210,
        //                                 child: Stack(
        //                                   children: [
        //                                     Image.asset(
        //                                       widget.darkMode
        //                                           ? 'assets/bggradientdarkmode.png'
        //                                           : 'assets/bggradient.png',
        //                                       fit: BoxFit.fill,
        //                                       width: double.infinity,
        //                                     ),
        //                                     Padding(
        //                                       padding: const EdgeInsets
        //                                           .symmetric(
        //                                         horizontal: 20,
        //                                         vertical: 60,
        //                                       ),
        //                                       child: Row(
        //                                         mainAxisAlignment:
        //                                             MainAxisAlignment
        //                                                 .spaceBetween,
        //                                         children: [
        //                                           FutureBuilder(
        //                                               future: _getLocal,
        //                                               builder: (BuildContext
        //                                                       context,
        //                                                   AsyncSnapshot<
        //                                                           dynamic>
        //                                                       snapshot) {
        //                                                 if (snapshot
        //                                                     .hasData) {
        //                                                   data =
        //                                                       snapshot.data;
        //                                                   return Expanded(
        //                                                     child: Row(
        //                                                       mainAxisAlignment:
        //                                                           MainAxisAlignment
        //                                                               .spaceBetween,
        //                                                       crossAxisAlignment:
        //                                                           CrossAxisAlignment
        //                                                               .start,
        //                                                       children: [
        //                                                         Expanded(
        //                                                           child:
        //                                                               Column(
        //                                                             crossAxisAlignment:
        //                                                                 CrossAxisAlignment.start,
        //                                                             children: [
        //                                                               InkWell(
        //                                                                 child:
        //                                                                     Text(
        //                                                                   '${greeting()},',
        //                                                                   style: reguler.copyWith(
        //                                                                     fontSize: 12,
        //                                                                     color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                   ),
        //                                                                 ),
        //                                                                 onTap:
        //                                                                     () async {
        //                                                                   // initClara();
        //                                                                   // SystemChrome
        //                                                                   //     .setPreferredOrientations([
        //                                                                   //   DeviceOrientation
        //                                                                   //       .landscapeLeft,
        //                                                                   //   DeviceOrientation
        //                                                                   //       .landscapeRight
        //                                                                   // ]);
        //                                                                 },
        //                                                               ),
        //                                                               AutoSizeText(
        //                                                                   data.Fullname == '' ? data.Username : data.Fullname,
        //                                                                   maxLines: 2,
        //                                                                   minFontSize: 14,
        //                                                                   maxFontSize: 16,
        //                                                                   overflow: TextOverflow.ellipsis,
        //                                                                   style: bold.copyWith(
        //                                                                     // fontSize: 16,
        //                                                                     color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                   )),
        //                                                               // Text(
        //                                                               //   data.Fullname == ''
        //                                                               //       ? data
        //                                                               //           .Username
        //                                                               //       : data
        //                                                               //           .Fullname,
        //                                                               //   style:
        //                                                               //       bold.copyWith(
        //                                                               //     fontSize: 16,
        //                                                               //     color:
        //                                                               //         whiteColor,
        //                                                               //   ),
        //                                                               // ),
        //                                                             ],
        //                                                           ),
        //                                                         ),
        //                                                         Column(
        //                                                           crossAxisAlignment:
        //                                                               CrossAxisAlignment
        //                                                                   .end,
        //                                                           children: [
        //                                                             GestureDetector(
        //                                                               child:
        //                                                                   Image.asset(
        //                                                                 'assets/whatsapp.png',
        //                                                                 width:
        //                                                                     100,
        //                                                               ),
        //                                                               onTap:
        //                                                                   () {
        //                                                                 // launchUrl(
        //                                                                 //     Uri.parse(url
        //                                                                 //         .data
        //                                                                 //         .results
        //                                                                 //         .whatsapp),
        //                                                                 //     mode:
        //                                                                 //         LaunchMode.externalApplication);
        //                                                                 showModalBottomSheet(
        //                                                                   isScrollControlled: true,
        //                                                                   isDismissible: true,
        //                                                                   shape: const RoundedRectangleBorder(
        //                                                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        //                                                                   ),
        //                                                                   backgroundColor: whiteCardColor,
        //                                                                   context: context,
        //                                                                   builder: (context) {
        //                                                                     return SingleChildScrollView(
        //                                                                       child: Container(
        //                                                                         padding: MediaQuery.of(context).viewInsets,
        //                                                                         alignment: Alignment.center,
        //                                                                         child: Padding(
        //                                                                           padding: const EdgeInsets.all(20.0),
        //                                                                           child: Column(
        //                                                                             children: [
        //                                                                               Stack(
        //                                                                                 children: [
        //                                                                                   Row(
        //                                                                                     mainAxisAlignment: MainAxisAlignment.center,
        //                                                                                     children: [
        //                                                                                       Text(AppLocalizations.of(context)!.needHelp, style: bold.copyWith(fontSize: 16, color: blackPrimary)),
        //                                                                                     ],
        //                                                                                   ),
        //                                                                                   InkWell(
        //                                                                                     onTap: () {},
        //                                                                                     child: Row(
        //                                                                                       mainAxisAlignment: MainAxisAlignment.end,
        //                                                                                       children: [
        //                                                                                         GestureDetector(
        //                                                                                           onTap: () {
        //                                                                                             Navigator.pop(context);
        //                                                                                           },
        //                                                                                           child: Icon(
        //                                                                                             Icons.close,
        //                                                                                             size: 30,
        //                                                                                             color: blackPrimary,
        //                                                                                           ),
        //                                                                                         ),
        //                                                                                       ],
        //                                                                                     ),
        //                                                                                   ),
        //                                                                                 ],
        //                                                                               ),
        //                                                                               Column(
        //                                                                                 children: [
        //                                                                                   Image.asset(
        //                                                                                     'assets/wadialog.png',
        //                                                                                     width: 200,
        //                                                                                     height: 200,
        //                                                                                   ),
        //                                                                                   const SizedBox(
        //                                                                                     height: 4,
        //                                                                                   ),
        //                                                                                   Text(
        //                                                                                     AppLocalizations.of(context)!.needHelpSub,
        //                                                                                     style: reguler.copyWith(fontSize: 10, color: blackSecondary3),
        //                                                                                     textAlign: TextAlign.center,
        //                                                                                   ),
        //                                                                                   const SizedBox(
        //                                                                                     height: 20,
        //                                                                                   ),
        //                                                                                 ],
        //                                                                               ),
        //                                                                               InkWell(
        //                                                                                 enableFeedback: url.data.branch.whatsapp == '' ? false : true,
        //                                                                                 onTap: () {
        //                                                                                   if (url.data.branch.whatsapp != '') {
        //                                                                                     launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
        //                                                                                     Navigator.pop(context);
        //                                                                                   }
        //                                                                                   // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
        //                                                                                 },
        //                                                                                 child: Padding(
        //                                                                                   padding: const EdgeInsets.only(top: 10, bottom: 5),
        //                                                                                   child: Container(
        //                                                                                     width: double.infinity,
        //                                                                                     decoration: BoxDecoration(
        //                                                                                       color: whiteColor,
        //                                                                                       // color: all ? blueGradient : whiteColor,
        //                                                                                       borderRadius: BorderRadius.circular(8),
        //                                                                                       border: Border.all(
        //                                                                                         width: 1,
        //                                                                                         color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
        //                                                                                       ),
        //                                                                                     ),
        //                                                                                     child: Row(
        //                                                                                       mainAxisAlignment: MainAxisAlignment.center,
        //                                                                                       children: [
        //                                                                                         Padding(
        //                                                                                           padding: const EdgeInsets.all(12),
        //                                                                                           child: Row(
        //                                                                                             children: [
        //                                                                                               // Icon(
        //                                                                                               //   Icons.whatsapp_outlined,
        //                                                                                               //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
        //                                                                                               //   size: 15,
        //                                                                                               // ),
        //                                                                                               Padding(
        //                                                                                                 padding: const EdgeInsets.only(left: 2),
        //                                                                                                 child: Text(AppLocalizations.of(context)!.installationBranch, style: bold.copyWith(fontSize: 12, color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary)),
        //                                                                                               ),
        //                                                                                             ],
        //                                                                                           ),
        //                                                                                         ),
        //                                                                                       ],
        //                                                                                     ),
        //                                                                                   ),
        //                                                                                 ),
        //                                                                               ),
        //                                                                               InkWell(
        //                                                                                 onTap: () {
        //                                                                                   // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
        //                                                                                   launchUrl(Uri.parse('https://wa.me/${url.data.head.whatsapp}'), mode: LaunchMode.externalApplication);
        //                                                                                   Navigator.pop(context);
        //                                                                                 },
        //                                                                                 child: Padding(
        //                                                                                   padding: const EdgeInsets.only(top: 10),
        //                                                                                   child: Container(
        //                                                                                     width: double.infinity,
        //                                                                                     decoration: BoxDecoration(
        //                                                                                       color: greenPrimary,
        //                                                                                       // color: all ? blueGradient : whiteColor,
        //                                                                                       borderRadius: BorderRadius.circular(8),
        //                                                                                       border: Border.all(
        //                                                                                         width: 1,
        //                                                                                         color: greenPrimary,
        //                                                                                       ),
        //                                                                                     ),
        //                                                                                     child: Row(
        //                                                                                       mainAxisAlignment: MainAxisAlignment.center,
        //                                                                                       children: [
        //                                                                                         Padding(
        //                                                                                           padding: const EdgeInsets.all(12),
        //                                                                                           child: Row(
        //                                                                                             children: [
        //                                                                                               // Icon(
        //                                                                                               //   Icons.whatsapp_outlined,
        //                                                                                               //   color: whiteColor,
        //                                                                                               //   size: 15,
        //                                                                                               // ),
        //                                                                                               Padding(
        //                                                                                                 padding: const EdgeInsets.only(left: 2),
        //                                                                                                 child: Text(AppLocalizations.of(context)!.cc24H, style: bold.copyWith(fontSize: 12, color: widget.darkMode ? whiteColorDarkMode : whiteColor)),
        //                                                                                               ),
        //                                                                                             ],
        //                                                                                           ),
        //                                                                                         ),
        //                                                                                       ],
        //                                                                                     ),
        //                                                                                   ),
        //                                                                                 ),
        //                                                                               ),
        //                                                                             ],
        //                                                                           ),
        //                                                                         ),
        //                                                                       ),
        //                                                                     );
        //                                                                   },
        //                                                                 );
        //                                                               },
        //                                                             ),
        //                                                           ],
        //                                                         ),
        //                                                       ],
        //                                                     ),
        //                                                   );
        //                                                 }
        //                                                 return Text(
        //                                                   '${AppLocalizations.of(context)!.gettingLocalData}...',
        //                                                   style:
        //                                                       bold.copyWith(
        //                                                     fontSize: 20,
        //                                                     color:
        //                                                         blueGradientSecondary1,
        //                                                   ),
        //                                                 );
        //                                               }),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                         Padding(
        //                           padding: const EdgeInsets.only(
        //                               left: 16,
        //                               right: 16,
        //                               top: 120,
        //                               bottom: 24),
        //                           child: Stack(
        //                             children: [
        //                               InkWell(
        //                                 onTap: () => Navigator.pushNamed(
        //                                     context, '/searchvehicle'),
        //                                 child: Image.asset(widget.darkMode
        //                                     ? AppLocalizations.of(context)!
        //                                         .searchHomeDark
        //                                     : AppLocalizations.of(context)!
        //                                         .searchHome),
        //                               ),
        //                               Visibility(
        //                                   visible: data.Username == 'demo'
        //                                       ? false
        //                                       : true,
        //                                   child: Padding(
        //                                     padding:
        //                                         const EdgeInsets.all(15.0),
        //                                     child: InkWell(
        //                                       // onTap: () => Navigator.pushNamed(
        //                                       //     context, '/sspoin'),
        //                                       onTap: () async {
        //                                         if (!disableSSpoin) {
        //                                           if (!ssPoin
        //                                               .data.isBlock) {
        //                                             await Navigator
        //                                                 .pushNamed(context,
        //                                                     '/sspoin');
        //                                             _getPoin = getPoin();
        //                                           }
        //                                         }
        //                                         // !disableSSpoin
        //                                         //     ? ssPoin.data.isBlock
        //                                         //         ? {}
        //                                         //         : Navigator.pushNamed(
        //                                         //             context, '/sspoin')
        //                                         //     : {};
        //                                       },
        //                                       child: Visibility(
        //                                           visible:
        //                                               !ssPoin.data.isBlock,
        //                                           child: Row(
        //                                             mainAxisAlignment:
        //                                                 MainAxisAlignment
        //                                                     .spaceBetween,
        //                                             children: [
        //                                               Row(
        //                                                 children: [
        //                                                   Image.asset(
        //                                                     'assets/sspoint.png',
        //                                                     width: 24,
        //                                                   ),
        //                                                   const SizedBox(
        //                                                     width: 9,
        //                                                   ),
        //                                                   FutureBuilder(
        //                                                     future:
        //                                                         _getPoin,
        //                                                     builder: (BuildContext
        //                                                             context,
        //                                                         AsyncSnapshot<
        //                                                                 dynamic>
        //                                                             snapshot) {
        //                                                       if (snapshot
        //                                                               .hasData &&
        //                                                           !sspoinLoading) {
        //                                                         if (snapshot
        //                                                                 .data
        //                                                             is ErrorTrapModel) {
        //                                                           return InkWell(
        //                                                             onTap:
        //                                                                 () {
        //                                                               // refreshPoin();
        //                                                               _getPoin =
        //                                                                   getPoin();
        //                                                             },
        //                                                             child:
        //                                                                 Row(
        //                                                               children: [
        //                                                                 Text(
        //                                                                   'Refresh',
        //                                                                   style: reguler.copyWith(
        //                                                                     fontSize: 14,
        //                                                                     color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                   ),
        //                                                                 ),
        //                                                                 Icon(
        //                                                                   Icons.refresh_rounded,
        //                                                                   size: 15,
        //                                                                   color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                 )
        //                                                               ],
        //                                                             ),
        //                                                           );
        //                                                         } else {
        //                                                           if (snapshot
        //                                                                   .data ==
        //                                                               false) {
        //                                                             // setState(() {
        //                                                             //   disableSSpoin = true;
        //                                                             // });
        //                                                             disableSSpoin =
        //                                                                 true;
        //                                                             return Text(
        //                                                               'NOT AVAILABLE',
        //                                                               style:
        //                                                                   reguler.copyWith(
        //                                                                 fontSize:
        //                                                                     14,
        //                                                                 color: widget.darkMode
        //                                                                     ? whiteColorDarkMode
        //                                                                     : whiteColor,
        //                                                               ),
        //                                                             );
        //                                                           } else {
        //                                                             if (snapshot.data
        //                                                                 is MessageModel) {
        //                                                               setState(
        //                                                                   () {
        //                                                                 disableSSpoin =
        //                                                                     true;
        //                                                               });
        //                                                               return InkWell(
        //                                                                 onTap:
        //                                                                     () {
        //                                                                   // refreshPoin();
        //                                                                   _getPoin = getPoin();
        //                                                                 },
        //                                                                 child:
        //                                                                     Row(
        //                                                                   children: [
        //                                                                     Text(
        //                                                                       'Refresh',
        //                                                                       style: reguler.copyWith(
        //                                                                         fontSize: 14,
        //                                                                         color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                       ),
        //                                                                     ),
        //                                                                     Icon(
        //                                                                       Icons.refresh_rounded,
        //                                                                       size: 15,
        //                                                                       color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                     )
        //                                                                   ],
        //                                                                 ),
        //                                                               );
        //                                                             } else {
        //                                                               ssPoin =
        //                                                                   snapshot.data;
        //                                                               return Visibility(
        //                                                                   visible: !ssPoin.data.isBlock,
        //                                                                   child: Text(
        //                                                                     '${ssPoin.data.currentPoint} SSPoin',
        //                                                                     style: reguler.copyWith(
        //                                                                       fontSize: 14,
        //                                                                       color: widget.darkMode ? whiteColorDarkMode : whiteColor,
        //                                                                     ),
        //                                                                   ));
        //                                                             }
        //                                                           }
        //                                                         }
        //                                                       }
        //                                                       return Container(
        //                                                         margin:
        //                                                             const EdgeInsets
        //                                                                 .only(
        //                                                           right: 12,
        //                                                         ),
        //                                                         width: 90,
        //                                                         height: 22,
        //                                                         child:
        //                                                             SkeletonTheme(
        //                                                           themeMode: widget.darkMode
        //                                                               ? ThemeMode
        //                                                                   .dark
        //                                                               : ThemeMode
        //                                                                   .light,
        //                                                           child:
        //                                                               SkeletonAvatar(
        //                                                             style: SkeletonAvatarStyle(
        //                                                                 shape: BoxShape
        //                                                                     .rectangle,
        //                                                                 width:
        //                                                                     140,
        //                                                                 borderRadius:
        //                                                                     BorderRadius.circular(10),
        //                                                                 height: 30),
        //                                                           ),
        //                                                         ),
        //                                                       );
        //                                                     },
        //                                                   ),
        //                                                 ],
        //                                               ),
        //                                               Icon(
        //                                                 Icons
        //                                                     .arrow_forward_ios,
        //                                                 color: widget
        //                                                         .darkMode
        //                                                     ? whiteColorDarkMode
        //                                                     : whiteColor,
        //                                                 size: 20,
        //                                               )
        //                                             ],
        //                                           )),
        //                                     ),
        //                                   )),
        //                             ],
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     Padding(
        //                       padding:
        //                           const EdgeInsets.symmetric(vertical: 10),
        //                       child: Column(
        //                         crossAxisAlignment:
        //                             CrossAxisAlignment.start,
        //                         children: [
        //                           Padding(
        //                             padding:
        //                                 const EdgeInsets.only(bottom: 32),
        //                             child: Column(
        //                               children: [
        //                                 Column(
        //                                   crossAxisAlignment:
        //                                       CrossAxisAlignment.start,
        //                                   children: [
        //                                     Padding(
        //                                       padding:
        //                                           const EdgeInsets.only(
        //                                         left: 16,
        //                                         right: 16,
        //                                       ),
        //                                       child: Column(
        //                                         children: [
        //                                           Text(
        //                                             AppLocalizations.of(
        //                                                     context)!
        //                                                 .unitStatus,
        //                                             style: bold.copyWith(
        //                                                 fontSize: 14,
        //                                                 color:
        //                                                     blackPrimary),
        //                                           ),
        //                                           const SizedBox(
        //                                             height: 12,
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                     gettingData
        //                                         ? SizedBox(
        //                                             width: double.infinity,
        //                                             height: 84,
        //                                             child: ListView(
        //                                               physics:
        //                                                   BouncingScrollPhysics(),
        //                                               padding:
        //                                                   EdgeInsets.only(
        //                                                       right: 16,
        //                                                       left: 16),
        //                                               scrollDirection:
        //                                                   Axis.horizontal,
        //                                               children: [
        //                                                 InkWell(
        //                                                   onTap: () {
        //                                                     // Navigator.pushNamed(
        //                                                     //     context, '/vehiclelist');
        //                                                   },
        //                                                   child:
        //                                                       StatusUnitCard(
        //                                                     StatusUnit(
        //                                                       mobil:
        //                                                           'assets/vehicle/car_moving.png',
        //                                                       status: AppLocalizations.of(
        //                                                               context)!
        //                                                           .all,
        //                                                       jumlah: allTotal
        //                                                           .toString(),
        //                                                       warna:
        //                                                           blackSecondary3,
        //                                                     ),
        //                                                     all: true,
        //                                                     darkmode: widget
        //                                                         .darkMode,
        //                                                   ),
        //                                                 ),
        //                                                 const SizedBox(
        //                                                   width: 12,
        //                                                 ),
        //                                                 FutureBuilder(
        //                                                     future:
        //                                                         _getMoving,
        //                                                     builder: (BuildContext
        //                                                             context,
        //                                                         AsyncSnapshot<
        //                                                                 dynamic>
        //                                                             snapshot) {
        //                                                       if (snapshot
        //                                                               .hasData &&
        //                                                           !movingLoading) {
        //                                                         if (snapshot
        //                                                                 .data
        //                                                             is ErrorTrapModel) {
        //                                                           //SKELETON
        //                                                           return SizedBox(
        //                                                             width:
        //                                                                 135,
        //                                                             height:
        //                                                                 84,
        //                                                             child:
        //                                                                 SkeletonTheme(
        //                                                               themeMode: widget.darkMode
        //                                                                   ? ThemeMode.dark
        //                                                                   : ThemeMode.light,
        //                                                               child:
        //                                                                   SkeletonAvatar(
        //                                                                 style:
        //                                                                     SkeletonAvatarStyle(
        //                                                                   borderRadius: BorderRadius.circular(10),
        //                                                                   shape: BoxShape.rectangle,
        //                                                                   width: 32,
        //                                                                   // height: 120
        //                                                                 ),
        //                                                               ),
        //                                                             ),
        //                                                           );
        //                                                         } else {
        //                                                           VehicleStatusModel
        //                                                               moving =
        //                                                               snapshot
        //                                                                   .data;
        //                                                           return InkWell(
        //                                                             onTap:
        //                                                                 () {
        //                                                               // Navigator.pushNamed(
        //                                                               //     context, '/vehiclelist');
        //                                                             },
        //                                                             child:
        //                                                                 StatusUnitCard(
        //                                                               StatusUnit(
        //                                                                 mobil:
        //                                                                     'assets/vehicle/car_moving.png',
        //                                                                 status:
        //                                                                     AppLocalizations.of(context)!.moving,
        //                                                                 jumlah:
        //                                                                     moving.data.unit.toString(),
        //                                                                 warna:
        //                                                                     bluePrimary,
        //                                                               ),
        //                                                               all:
        //                                                                   false,
        //                                                               darkmode:
        //                                                                   widget.darkMode,
        //                                                             ),
        //                                                           );
        //                                                         }
        //                                                       }
        //                                                       //SKELETON
        //                                                       return SizedBox(
        //                                                         width: 135,
        //                                                         height: 84,
        //                                                         child:
        //                                                             SkeletonTheme(
        //                                                           themeMode: widget.darkMode
        //                                                               ? ThemeMode
        //                                                                   .dark
        //                                                               : ThemeMode
        //                                                                   .light,
        //                                                           child:
        //                                                               SkeletonAvatar(
        //                                                             style:
        //                                                                 SkeletonAvatarStyle(
        //                                                               borderRadius:
        //                                                                   BorderRadius.circular(10),
        //                                                               shape:
        //                                                                   BoxShape.rectangle,
        //                                                               width:
        //                                                                   32,
        //                                                               // height: 120
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                       );
        //                                                     }),
        //                                                 const SizedBox(
        //                                                   width: 12,
        //                                                 ),
        //                                                 FutureBuilder(
        //                                                     future:
        //                                                         _getPark,
        //                                                     builder: (BuildContext
        //                                                             context,
        //                                                         AsyncSnapshot<
        //                                                                 dynamic>
        //                                                             snapshot) {
        //                                                       if (snapshot
        //                                                               .hasData &&
        //                                                           !parkLoading) {
        //                                                         if (snapshot
        //                                                                 .data
        //                                                             is ErrorTrapModel) {
        //                                                           //SKELETON
        //                                                           return SizedBox(
        //                                                             width:
        //                                                                 135,
        //                                                             height:
        //                                                                 84,
        //                                                             child:
        //                                                                 SkeletonTheme(
        //                                                               themeMode: widget.darkMode
        //                                                                   ? ThemeMode.dark
        //                                                                   : ThemeMode.light,
        //                                                               child:
        //                                                                   SkeletonAvatar(
        //                                                                 style:
        //                                                                     SkeletonAvatarStyle(
        //                                                                   borderRadius: BorderRadius.circular(10),
        //                                                                   shape: BoxShape.rectangle,
        //                                                                   width: 32,
        //                                                                   // height: 120
        //                                                                 ),
        //                                                               ),
        //                                                             ),
        //                                                           );
        //                                                         } else {
        //                                                           VehicleStatusModel
        //                                                               park =
        //                                                               snapshot
        //                                                                   .data;
        //                                                           return InkWell(
        //                                                             onTap:
        //                                                                 () {
        //                                                               // Navigator.pushNamed(
        //                                                               //     context, '/vehiclelist');
        //                                                             },
        //                                                             child:
        //                                                                 StatusUnitCard(
        //                                                               StatusUnit(
        //                                                                 mobil:
        //                                                                     'assets/vehicle/car_stop.png',
        //                                                                 status:
        //                                                                     AppLocalizations.of(context)!.park,
        //                                                                 jumlah:
        //                                                                     park.data.unit.toString(),
        //                                                                 warna:
        //                                                                     blackPrimary,
        //                                                               ),
        //                                                               all:
        //                                                                   false,
        //                                                               darkmode:
        //                                                                   widget.darkMode,
        //                                                             ),
        //                                                           );
        //                                                         }
        //                                                       }
        //                                                       //SKELETON
        //                                                       return SizedBox(
        //                                                         width: 135,
        //                                                         height: 84,
        //                                                         child:
        //                                                             SkeletonTheme(
        //                                                           themeMode: widget.darkMode
        //                                                               ? ThemeMode
        //                                                                   .dark
        //                                                               : ThemeMode
        //                                                                   .light,
        //                                                           child:
        //                                                               SkeletonAvatar(
        //                                                             style:
        //                                                                 SkeletonAvatarStyle(
        //                                                               borderRadius:
        //                                                                   BorderRadius.circular(10),
        //                                                               shape:
        //                                                                   BoxShape.rectangle,
        //                                                               width:
        //                                                                   32,
        //                                                               // height: 120
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                       );
        //                                                     }),
        //                                                 const SizedBox(
        //                                                   width: 12,
        //                                                 ),
        //                                                 FutureBuilder(
        //                                                     future:
        //                                                         _getStop,
        //                                                     builder: (BuildContext
        //                                                             context,
        //                                                         AsyncSnapshot<
        //                                                                 dynamic>
        //                                                             snapshot) {
        //                                                       if (snapshot
        //                                                               .hasData &&
        //                                                           !stopLoading) {
        //                                                         if (snapshot
        //                                                                 .data
        //                                                             is ErrorTrapModel) {
        //                                                           //SKELETON
        //                                                           return SizedBox(
        //                                                             width:
        //                                                                 135,
        //                                                             height:
        //                                                                 84,
        //                                                             child:
        //                                                                 SkeletonTheme(
        //                                                               themeMode: widget.darkMode
        //                                                                   ? ThemeMode.dark
        //                                                                   : ThemeMode.light,
        //                                                               child:
        //                                                                   SkeletonAvatar(
        //                                                                 style:
        //                                                                     SkeletonAvatarStyle(
        //                                                                   borderRadius: BorderRadius.circular(10),
        //                                                                   shape: BoxShape.rectangle,
        //                                                                   width: 32,
        //                                                                   // height: 120
        //                                                                 ),
        //                                                               ),
        //                                                             ),
        //                                                           );
        //                                                         } else {
        //                                                           VehicleStatusModel
        //                                                               stop =
        //                                                               snapshot
        //                                                                   .data;

        //                                                           return InkWell(
        //                                                             onTap:
        //                                                                 () {
        //                                                               // Navigator.pushNamed(
        //                                                               //     context, '/vehiclelist');
        //                                                             },
        //                                                             child:
        //                                                                 StatusUnitCard(
        //                                                               StatusUnit(
        //                                                                   mobil: 'assets/vehicle/car_stop.png',
        //                                                                   status: AppLocalizations.of(context)!.stop,
        //                                                                   jumlah: stop.data.unit.toString(),
        //                                                                   warna: blackPrimary),
        //                                                               all:
        //                                                                   false,
        //                                                               darkmode:
        //                                                                   widget.darkMode,
        //                                                             ),
        //                                                           );
        //                                                         }
        //                                                       }
        //                                                       //SKELETON
        //                                                       return SizedBox(
        //                                                         width: 135,
        //                                                         height: 84,
        //                                                         child:
        //                                                             SkeletonTheme(
        //                                                           themeMode: widget.darkMode
        //                                                               ? ThemeMode
        //                                                                   .dark
        //                                                               : ThemeMode
        //                                                                   .light,
        //                                                           child:
        //                                                               SkeletonAvatar(
        //                                                             style:
        //                                                                 SkeletonAvatarStyle(
        //                                                               borderRadius:
        //                                                                   BorderRadius.circular(10),
        //                                                               shape:
        //                                                                   BoxShape.rectangle,
        //                                                               width:
        //                                                                   32,
        //                                                               // height: 120
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                       );
        //                                                     }),
        //                                                 // ),
        //                                                 const SizedBox(
        //                                                   width: 12,
        //                                                 ),
        //                                                 // StatusUnitCard(
        //                                                 //   StatusUnit(
        //                                                 //       mobil: 'assets/mobil_nodata.png',
        //                                                 //       status: AppLocalizations.of(context)!.noData,
        //                                                 //       jumlah: '7',
        //                                                 //       warna: bluePrimary),
        //                                                 // ),
        //                                                 FutureBuilder(
        //                                                     future:
        //                                                         _getNoData,
        //                                                     builder: (BuildContext
        //                                                             context,
        //                                                         AsyncSnapshot<
        //                                                                 dynamic>
        //                                                             snapshot) {
        //                                                       if (snapshot
        //                                                               .hasData &&
        //                                                           !lostLoading) {
        //                                                         if (snapshot
        //                                                                 .data
        //                                                             is ErrorTrapModel) {
        //                                                           //SKELETON
        //                                                           return SizedBox(
        //                                                             width:
        //                                                                 135,
        //                                                             height:
        //                                                                 84,
        //                                                             child:
        //                                                                 SkeletonTheme(
        //                                                               themeMode: widget.darkMode
        //                                                                   ? ThemeMode.dark
        //                                                                   : ThemeMode.light,
        //                                                               child:
        //                                                                   SkeletonAvatar(
        //                                                                 style:
        //                                                                     SkeletonAvatarStyle(
        //                                                                   borderRadius: BorderRadius.circular(10),
        //                                                                   shape: BoxShape.rectangle,
        //                                                                   width: 32,
        //                                                                   // height: 120
        //                                                                 ),
        //                                                               ),
        //                                                             ),
        //                                                           );
        //                                                         } else {
        //                                                           VehicleStatusModel
        //                                                               noData =
        //                                                               snapshot
        //                                                                   .data;

        //                                                           return InkWell(
        //                                                             onTap:
        //                                                                 () {
        //                                                               // Navigator.pushNamed(
        //                                                               //     context, '/vehiclelist');
        //                                                             },
        //                                                             child:
        //                                                                 StatusUnitCard(
        //                                                               StatusUnit(
        //                                                                   mobil: 'assets/vehicle/car_lost.png',
        //                                                                   status: AppLocalizations.of(context)!.lost,
        //                                                                   jumlah: noData.data.unit.toString(),
        //                                                                   warna: yellowPrimary),
        //                                                               all:
        //                                                                   false,
        //                                                               darkmode:
        //                                                                   widget.darkMode,
        //                                                             ),
        //                                                           );
        //                                                         }
        //                                                       }
        //                                                       //SKELETON
        //                                                       return SizedBox(
        //                                                         width: 135,
        //                                                         height: 84,
        //                                                         child:
        //                                                             SkeletonTheme(
        //                                                           themeMode: widget.darkMode
        //                                                               ? ThemeMode
        //                                                                   .dark
        //                                                               : ThemeMode
        //                                                                   .light,
        //                                                           child:
        //                                                               SkeletonAvatar(
        //                                                             style:
        //                                                                 SkeletonAvatarStyle(
        //                                                               borderRadius:
        //                                                                   BorderRadius.circular(10),
        //                                                               shape:
        //                                                                   BoxShape.rectangle,
        //                                                               width:
        //                                                                   32,
        //                                                               // height: 120
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                       );
        //                                                     })
        //                                               ],
        //                                             ),
        //                                           )
        //                                         : SizedBox(
        //                                             // width: 135,
        //                                             height: 84,
        //                                             child: Padding(
        //                                               padding:
        //                                                   const EdgeInsets
        //                                                           .symmetric(
        //                                                       horizontal:
        //                                                           10),
        //                                               child: SkeletonTheme(
        //                                                 themeMode: widget
        //                                                         .darkMode
        //                                                     ? ThemeMode.dark
        //                                                     : ThemeMode
        //                                                         .light,
        //                                                 child:
        //                                                     SkeletonAvatar(
        //                                                   style: SkeletonAvatarStyle(
        //                                                       borderRadius:
        //                                                           BorderRadius
        //                                                               .circular(
        //                                                                   10),
        //                                                       shape: BoxShape
        //                                                           .rectangle,
        //                                                       width: double
        //                                                           .infinity,
        //                                                       height: 84),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           )
        //                                   ],
        //                                 ),
        //                               ],
        //                             ),
        //                           ),
        //                           Column(
        //                             crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                             children: [
        //                               Padding(
        //                                 padding: const EdgeInsets.only(
        //                                     left: 16, right: 16),
        //                                 child: Column(
        //                                   crossAxisAlignment:
        //                                       CrossAxisAlignment.start,
        //                                   children: [
        //                                     Text(
        //                                       AppLocalizations.of(context)!
        //                                           .fyi,
        //                                       style: bold.copyWith(
        //                                         fontSize: 14,
        //                                         color: blackPrimary,
        //                                       ),
        //                                     ),
        //                                     const SizedBox(
        //                                       height: 4,
        //                                     ),
        //                                     Text(
        //                                       AppLocalizations.of(context)!
        //                                           .thankYouForTrustingUs,
        //                                       style: reguler.copyWith(
        //                                         fontSize: 10,
        //                                         color: widget.darkMode
        //                                             ? whiteColorDarkMode
        //                                             : blackSecondary3,
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ),
        //                               Transform.translate(
        //                                 offset: Offset(0, -14),
        //                                 child: FutureBuilder(
        //                                     future: _getBanner,
        //                                     builder: (BuildContext context,
        //                                         AsyncSnapshot<dynamic>
        //                                             snapshot) {
        //                                       if (snapshot.hasData &&
        //                                           !bannerLoading) {
        //                                         if (snapshot.data
        //                                             is ErrorTrapModel) {
        //                                           //SKELETON
        //                                           return Padding(
        //                                             padding:
        //                                                 const EdgeInsets
        //                                                         .only(
        //                                                     bottom: 30,
        //                                                     left: 10,
        //                                                     right: 10),
        //                                             child: SizedBox(
        //                                               width:
        //                                                   double.infinity,
        //                                               height: 160,
        //                                               child: SkeletonTheme(
        //                                                 themeMode: widget
        //                                                         .darkMode
        //                                                     ? ThemeMode.dark
        //                                                     : ThemeMode
        //                                                         .light,
        //                                                 child:
        //                                                     SkeletonAvatar(
        //                                                   style:
        //                                                       SkeletonAvatarStyle(
        //                                                     borderRadius:
        //                                                         BorderRadius
        //                                                             .circular(
        //                                                                 10),
        //                                                     shape: BoxShape
        //                                                         .rectangle,
        //                                                     width: 32,
        //                                                     // height: 120
        //                                                   ),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           );
        //                                         } else {
        //                                           List<Result> banners =
        //                                               snapshot.data;
        //                                           return CarouselSlider
        //                                               .builder(
        //                                                   // itemCount: 5,
        //                                                   itemCount: banners
        //                                                       .length,
        //                                                   itemBuilder:
        //                                                       (context,
        //                                                           index,
        //                                                           realIndex) {
        //                                                     return InkWell(
        //                                                       onTap: () {
        //                                                         banners[index]
        //                                                                 .Url_link
        //                                                                 .isNotEmpty
        //                                                             ? launchUrl(
        //                                                                 Uri.parse(banners[index]
        //                                                                     .Url_link),
        //                                                                 mode:
        //                                                                     LaunchMode.externalApplication)
        //                                                             : {};
        //                                                         // print(
        //                                                         //     'Banner tap: ${banners[index].Name}');
        //                                                         // launchUrl(
        //                                                         //     Uri.parse(banners[
        //                                                         //             index]
        //                                                         //         .FileMobile),
        //                                                         //     mode: LaunchMode
        //                                                         //         .externalApplication);
        //                                                       },
        //                                                       child:
        //                                                           Padding(
        //                                                         padding: const EdgeInsets
        //                                                                 .only(
        //                                                             left:
        //                                                                 16),
        //                                                         child: Image
        //                                                             .network(
        //                                                           banners[index]
        //                                                               .FileMobile,
        //                                                         ),
        //                                                       ),
        //                                                     );
        //                                                   },
        //                                                   options: CarouselOptions(
        //                                                       autoPlay: true,
        //                                                       // enlargeCenterPage:
        //                                                       //     true,
        //                                                       // aspectRatio: 16 / 9,
        //                                                       padEnds: false,
        //                                                       // viewportFraction: 0.77,
        //                                                       enableInfiniteScroll: false));
        //                                         }
        //                                       }
        //                                       return Padding(
        //                                         padding:
        //                                             const EdgeInsets.only(
        //                                                 bottom: 30,
        //                                                 left: 10,
        //                                                 right: 10),
        //                                         child: SizedBox(
        //                                           width: double.infinity,
        //                                           height: 160,
        //                                           child: SkeletonTheme(
        //                                             themeMode: widget
        //                                                     .darkMode
        //                                                 ? ThemeMode.dark
        //                                                 : ThemeMode.light,
        //                                             child: SkeletonAvatar(
        //                                               style:
        //                                                   SkeletonAvatarStyle(
        //                                                 borderRadius:
        //                                                     BorderRadius
        //                                                         .circular(
        //                                                             10),
        //                                                 shape: BoxShape
        //                                                     .rectangle,
        //                                                 width: 32,
        //                                                 // height: 120
        //                                               ),
        //                                             ),
        //                                           ),
        //                                         ),
        //                                       );
        //                                     }),
        //                               ),
        //                               // const SizedBox(
        //                               //   height: 30,
        //                               // ),
        //                             ],
        //                           ),
        //                           Transform.translate(
        //                             offset: Offset(0, -10),
        //                             child: Visibility(
        //                               visible: data.Username == 'demo'
        //                                   ? false
        //                                   : true,
        //                               child: Padding(
        //                                 padding: const EdgeInsets.only(
        //                                     left: 16, right: 16),
        //                                 child: Column(
        //                                   crossAxisAlignment:
        //                                       CrossAxisAlignment.start,
        //                                   children: [
        //                                     Text(
        //                                       AppLocalizations.of(context)!
        //                                           .checkSubscription,
        //                                       style: bold.copyWith(
        //                                         fontSize: 14,
        //                                         color: blackPrimary,
        //                                       ),
        //                                     ),
        //                                     const SizedBox(
        //                                       height: 8,
        //                                     ),
        //                                     ClipRRect(
        //                                         borderRadius:
        //                                             BorderRadius.circular(
        //                                                 8),
        //                                         child: InkWell(
        //                                           onTap: () =>
        //                                               Navigator.pushNamed(
        //                                                   context,
        //                                                   '/expiredvehiclelist'),
        //                                           child: Image.asset(
        //                                               AppLocalizations.of(
        //                                                       context)!
        //                                                   .checkSubsImg),
        //                                         )),
        //                                     const SizedBox(
        //                                       height: 32,
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                           Padding(
        //                             padding: EdgeInsets.only(
        //                                 left: 16, right: 16),
        //                             child: Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               children: [
        //                                 Row(
        //                                   mainAxisAlignment:
        //                                       MainAxisAlignment
        //                                           .spaceBetween,
        //                                   children: [
        //                                     Text(
        //                                       AppLocalizations.of(context)!
        //                                           .ourProduct,
        //                                       style: bold.copyWith(
        //                                         fontSize: 14,
        //                                         color: blackPrimary,
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 ),
        //                                 const SizedBox(
        //                                   height: 8,
        //                                 ),
        //                                 ClipRRect(
        //                                   borderRadius: BorderRadius.all(
        //                                       Radius.circular(8)),
        //                                   child: InkWell(
        //                                     onTap: () =>
        //                                         Navigator.pushNamed(context,
        //                                             '/productlist'),
        //                                     child: Image.asset(
        //                                         AppLocalizations.of(
        //                                                 context)!
        //                                             .product),
        //                                   ),
        //                                 ),
        //                                 const SizedBox(
        //                                   height: 20,
        //                                 ),
        //                               ],
        //                             ),
        //                           )
        //                         ],
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               )),
        //           selected == 1
        //               ? NotificationPage(
        //                   fromNotif: false,
        //                   id: 0,
        //                   darkMode: widget.darkMode,
        //                 )
        //               : const Center(),
        //           // const Tracking(),
        //           // const LandingCart(),
        //           const Center(),
        //           selected == 3
        //               ? LandingCart(
        //                   darkMode: widget.darkMode,
        //                 )
        //               : const Center(),
        //           OtherPage(
        //             darkMode: widget.darkMode,
        //           ),
        //         ],
        //       ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(
            // horizontal: 20,
            vertical: 12,
          ),
          // width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: widget.darkMode ? blackSecondary1 : greyColor,
              ),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: data.Username == 'demo' || imeiDemo == '123456'
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: bottomNavbarItem(
                    'assets/home_icon.png',
                    'assets/icon/home_active.png',
                    'assets/icon/home_inactive.png',
                    'Home',
                    0,
                    false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: bottomNavbarItem(
                    'assets/notif_icon.png',
                    'assets/icon/notif_active.png',
                    'assets/icon/notif_inactive.png',
                    'Notifications',
                    1,
                    false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: bottomNavbarItem(
                    'assets/map_icon.png',
                    'assets/icon/tracking.png',
                    'assets/icon/tracking.png',
                    'Tracking',
                    2,
                    true,
                  ),
                ),
                Visibility(
                    visible: data.Username == 'demo' || imeiDemo == '123456'
                        ? false
                        : true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: bottomNavbarItem(
                        'assets/wallet_icon.png',
                        'assets/icon/topup_active.png',
                        'assets/icon/topup_inactive.png',
                        'Topup',
                        3,
                        false,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: bottomNavbarItem(
                    'assets/profile_icon.png',
                    'assets/icon/profile_active.png',
                    'assets/icon/profile_inactive.png',
                    'Profile',
                    4,
                    false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector bottomNavbarItem(
    String imageUrl,
    String iconActive,
    String iconInctive,
    String text,
    int index,
    bool tracker,
  ) {
    if (tracker) {
      return GestureDetector(
        onTap: () {
          // setState(() {
          //   selected = index;
          // });
          Navigator.pushNamed(context, '/tracking');
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 6.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/tracking.png',
                width: 24,
                color: widget.darkMode ? whiteColorDarkMode : null,
              ),
              Text(
                'Tracking',
                style: bold.copyWith(
                    fontSize: 8.5,
                    color: widget.darkMode ? whiteColorDarkMode : blueGradient),
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          print('clicked = $index');
          setState(() {
            selected = index;
          });
          // text == 'Topup' ? Navigator.pushNamed(context, '/landingcart') : {};
        },
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // selected == index
                  //     ? Icon(Icons.iconac)
                  //     : Icon,
                  selected == index
                      ? Image.asset(
                          iconActive,
                          width: 24,
                          color: widget.darkMode ? whiteColorDarkMode : null,
                        )
                      : Image.asset(
                          iconInctive,
                          width: 24,
                          color: widget.darkMode ? whiteColorDarkMode : null,
                        ),
                  // Image.asset(
                  //   imageUrl,
                  //   width: 24,
                  //   color: selected == index ? bluePrimary : greyColor,
                  // ),
                  Text(
                    text,
                    style: widget.darkMode
                        ? bold.copyWith(
                            fontSize: 8.5,
                            color: selected == index
                                ? whiteColorDarkMode
                                : whiteColorDarkMode,
                          )
                        : reguler.copyWith(
                            fontSize: 8.5,
                            color: selected == index
                                ? bluePrimary
                                : blackSecondary3,
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // _timer.isActive ? _timer.cancel() : {};
    super.dispose();
  }
}
