// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/pages/fullscreenvlc.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// class SampleTest {
//   @override
//   void initState() async {
//     readTheme();
//   }

//   readTheme() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
//     final bool? darkmode = prefs.getBool('darkmode');
//     darkMode = darkmode!;
//     print(darkmode);
//   }
// }

double _widthBtn = 240.0;
// Black Color
Color blackPrimary = const Color(0xff202020);
Color blackSecondary1 = const Color(0xff404040);
Color blackSecondary2 = const Color(0xff606060);
Color blackSecondary3 = const Color(0xff808080);

//Grey Color
Color greyColor = const Color(0xffcacaca);
Color greyColorSecondary = const Color(0xffe4e4e4);

//Card Color
Color whiteCardColor = const Color(0xFFF2F5F7);

//White Color
Color whiteColor = const Color(0xffFFFFFF);
Color whiteColorDarkMode = const Color(0xFFF2F5F7);

//Red Color
Color redPrimary = const Color(0xffe74d4d);
Color redSecondary = const Color(0xffffdede);

//Green Color
Color greenPrimary = const Color(0xff08c10f);
Color greenSecondary = const Color(0xffceffd0);

//Blue Color
Color bluePrimary = const Color(0xff45a4dd);
Color blueSecondary = const Color(0xff77bbe4);

//Purple Color
Color purplePrimary = const Color(0xff797ee8);
Color purpleSecondary = const Color(0xffc9cbff);

//Yellow Color
Color yellowPrimary = const Color(0xffffb82e);
Color yellowSecondary = const Color(0xfffff4de);

//Gradient blue-purple Color
Color blueGradient = const Color(0xff45a4dd);
Color purpleGradient = const Color(0xff797ee8);

//Gradient blue-blue Color
Color blueGradientSecondary1 = const Color(0xff77bbe4);
Color blueGradientSecondary2 = const Color(0xff45a4dd);

//Gradient Blue-Green-Yellow
Color bgy1 = const Color(0xff45a4dd);
Color bgy2 = const Color(0xff08C10F);
Color bgy3 = const Color(0xffFFC452);

class ColorTheme {
  late bool darkMode;
  readTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
    final bool? darkmode = prefs.getBool('darkmode');
    darkMode = darkmode!;
    print(darkmode);
    if (darkMode) {
      // Black Color
      blackPrimary = const Color(0xffFFFFFF);

//Card Color
      whiteCardColor = const Color(0xFF002235);

//White Color
      whiteColor = const Color(0xff00131E);
    }
  }
}

//Text Style
TextStyle bold = GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
);

TextStyle reguler = GoogleFonts.poppins(
  fontWeight: FontWeight.w400,
);

setTitleCase(String text) {
  ReCase rc = ReCase(text);
  return rc.titleCase;
}

Widget _updateNow(BuildContext _context) {
  return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            colors: [blueGradientSecondary2, blueGradientSecondary1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          )),
      width: _widthBtn,
      height: 35,
      child: InkWell(
        onTap: () {
          if (Platform.isAndroid) {
            Navigator.of(_context).pop();
            launch(
                'https://play.google.com/store/apps/details?id=com.superspring.gpsid');
          }
          if (Platform.isIOS) {
            Navigator.of(_context).pop();
            launch(
                'https://apps.apple.com/id/app/gps-id-dari-super-spring/id1119572414?uo=4');
          }
        },
        child: Center(
          child: Text(
            AppLocalizations.of(_context)!.updateNow,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColorDarkMode,
            ),
          ),
        ),
      ));
}

Widget _updateLater(BuildContext _context) {
  return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: yellowPrimary),
      width: _widthBtn,
      height: 35,
      child: InkWell(
        onTap: () {
          Navigator.of(_context).pop();
        },
        child: Center(
          child: Text(
            AppLocalizations.of(_context)!.updateLater,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColorDarkMode,
            ),
          ),
        ),
      ));
}

Widget getIconLoading() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      SpinKitDoubleBounce(
        size: 48.0,
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven
                  ? Theme.of(context).primaryColor.withOpacity(0.5)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
          );
        },
        duration: const Duration(
          milliseconds: 1600,
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      StatefulBuilder(builder: (BuildContext context1, StateSetter setState) {
        return Text(
          setTitleCase(
            'Please wait',
          ),
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        );
      }),
    ],
  );
}

Widget _closePopButton(BuildContext context) {
  return SizedBox(
    width: _widthBtn,
    child: ElevatedButton(
        child: const Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // Navigator.of(_context).pop();
          Navigator.pop(context);
        }),
  );
}

redeemPoint(BuildContext context, int id, String note) async {
  Navigator.pop(context);
  Dialogs().loadingDialog(context);
  final result = await APIService().redeemPoin(id, note);
  if (result is MessageModel) {
    if (result.status == true) {
      Dialogs().hideLoaderDialog(context);
      showSuccess(context, result.message);
    } else {
      Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, result.message, '');
    }
  } else {
    Dialogs().hideLoaderDialog(context);
    showInfoAlert(context, result.message, '');
  }
}

Widget whatsappButton(BuildContext context) {
  return ElevatedButton(
      child: Image.asset(
        'assets/whatsapp.png',
        width: 100,
      ),
      onPressed: () {
        // Navigator.of(_context).pop();
        Navigator.pop(context);
      });
}

Widget _closePopButtonSuccess(BuildContext context) {
  return SizedBox(
    width: _widthBtn,
    child: ElevatedButton(
        child: const Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // Navigator.of(_context).pop();
          Navigator.pop(context);
          // Navigator.pop(context);
          // Navigator.pop(context);
          // Navigator.pop(context);
        }),
  );
}

Widget _closePopButtonSuccessEditProfile(BuildContext context) {
  return SizedBox(
    width: _widthBtn,
    child: ElevatedButton(
        child: const Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          // Navigator.of(_context).pop();
          await Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (route) => false);
          // Navigator.pop(context);
          // Navigator.pushReplacementNamed(context, '/');
          // Navigator.pop(context);
          // Navigator.pop(context);
          // Navigator.pop(context);
        }),
  );
}

// vlcPlayerFullScreen(
//     BuildContext context, VlcPlayerController controller) async {
//   SystemChrome.setPreferredOrientations([
//     MediaQuery.of(context).orientation == Orientation.portrait
//         ? DeviceOrientation.landscapeRight
//         : DeviceOrientation.portraitUp
//   ]);
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AspectRatio(
//         aspectRatio: 9 / 16,
//         child: VlcPlayer(
//           controller: controller,
//           aspectRatio: 16 / 9,
//           placeholder: Container(
//             color: blackPrimary,
//             child: const Center(child: CircularProgressIndicator()),
//           ),
//         ),
//       );
//     },
//   );
// }

vlcPLayer(
    BuildContext context,
    VlcPlayerController controller,
    String url,
    String limit,
    String camera,
    String imei,
    String file,
    bool darkMode) async {
  // String time = '';
  String startTime = '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String time = '';
      // return alert;
      String _printDurationII(Duration duration) {
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        return " ${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          controller = VlcPlayerController.network(url,
              autoInitialize: true, autoPlay: true);
          controller.addListener(() {
            time = controller.value.position.inSeconds.toString();
            // time = controller.value.position.inSeconds.toString();
            if (controller.value.position.inSeconds == 1) {
              startTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(DateTime.now().toLocal());
            }
            if (controller.value.isEnded) {
              print('isEnded');
            }
          });

          return Dialog(
            backgroundColor: darkMode ? whiteCardColor : blackPrimary,
            insetPadding: const EdgeInsets.all(5),
            alignment: Alignment.topCenter,
            child: AspectRatio(
                aspectRatio: 16 / 13,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/icon/dashcam/redDot.png',
                                width: 8,
                                height: 8,
                              ),
                              Text(
                                // 'Limit Stream : ${_printDurationII(Duration(seconds: widget.limit))} / $_refreshLabelDashcam',
                                'Limit Stream : ${_printDurationII(Duration(seconds: int.parse(limit)))}',
                                style: reguler.copyWith(
                                    color: darkMode
                                        ? whiteColorDarkMode
                                        : whiteColor,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (controller.value.isInitialized) {
                              controller.stop();
                              Dialogs().loadingDialog(context);
                              String action = '2';
                              camera;
                              time;
                              startTime;
                              String finishTime =
                                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                      DateTime.parse(startTime).add(
                                          Duration(seconds: int.parse(time))));
                              final result = await APIService().storeLimit(
                                  startTime,
                                  finishTime.toString(),
                                  controller.value.position.inSeconds
                                      .toString(),
                                  imei,
                                  action,
                                  camera,
                                  file);
                              if (result is MessageModel) {
                                Dialogs().hideLoaderDialog(context);
                                showInfoAlert(context, result.message, '');
                              } else {
                                controller.dispose();
                                Dialogs().hideLoaderDialog(context);
                                Navigator.pop(context);
                                print('quota : $time');
                              }
                            } else {
                              Navigator.pop(context);
                            }
                            // controller.value.isInitialized
                            //     ? controller.stop()
                            //     : {};
                          },
                          child: Icon(
                            Icons.close,
                            size: 30,
                            color: darkMode ? whiteColorDarkMode : whiteColor,
                          ),
                        ),
                      ],
                    ),
                    VlcPlayer(
                        controller: controller,
                        aspectRatio: 16 / 9,
                        placeholder: Container(
                          color: blackPrimary,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (controller.value.isPlaying) {
                              controller.pause();
                              Dialogs().loadingDialog(context);
                              String action = '2';
                              camera;
                              time;
                              startTime;
                              String finishTime =
                                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                      DateTime.parse(startTime).add(
                                          Duration(seconds: int.parse(time))));
                              final result = await APIService().storeLimit(
                                  startTime,
                                  finishTime.toString(),
                                  controller.value.position.inSeconds
                                      .toString(),
                                  imei,
                                  action,
                                  camera,
                                  file);
                              if (result is MessageModel) {
                                Dialogs().hideLoaderDialog(context);
                                showInfoAlert(context, result.message, '');
                              } else {
                                Dialogs().hideLoaderDialog(context);
                                // Navigator.pop(context);
                                print('quota : $time');
                              }
                            } else {
                              controller.play();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icon/dashcam/play.png',
                                // controller.value.isPlaying
                                //     ? 'assets/icon/dashcam/pause.png'
                                //     : 'assets/icon/dashcam/play.png',
                                width: 24,
                                height: 24,
                                color:
                                    darkMode ? whiteColorDarkMode : whiteColor,
                              ),
                              Image.asset(
                                // controller.value.isPlaying
                                //     ? 'assets/icon/dashcam/pause.png'
                                //     : 'assets/icon/dashcam/play.png',
                                'assets/icon/dashcam/pause.png',
                                width: 24,
                                height: 24,
                                color:
                                    darkMode ? whiteColorDarkMode : whiteColor,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Future<String> saveImage(Uint8List bytes) async {
                              await [Permission.storage].request();
                              final time = DateTime.now()
                                  .toIso8601String()
                                  .replaceAll('.', '-')
                                  .replaceAll(':', '-');
                              final name = 'SS_$time';
                              final result = await ImageGallerySaver.saveImage(
                                  bytes,
                                  name: name);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text("Image saved to gallery"),
                                backgroundColor: blueGradient,
                              ));
                              return Platform.isAndroid
                                  ? result['filePath']
                                  : '';
                            }

                            final image = await controller.takeSnapshot();
                            await saveImage(image);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Image.asset(
                              'assets/icon/dashcam/screenshot.png',
                              width: 24,
                              height: 24,
                              color: darkMode ? whiteColorDarkMode : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            controller.value.volume == 100
                                ? controller.setVolume(0)
                                : controller.setVolume(100);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Image.asset(
                              controller.value.volume == 100
                                  ? 'assets/icon/dashcam/sound.png'
                                  : 'assets/icon/dashcam/mutesound.png',
                              width: 24,
                              height: 24,
                              color: darkMode ? whiteColorDarkMode : whiteColor,
                            ),
                          ),
                        ),
                        InkWell(
                          child: Icon(
                            Icons.fullscreen,
                            color: darkMode ? whiteColorDarkMode : whiteColor,
                            size: 24,
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(PageTransition(
                              child: Scaffold(
                                backgroundColor: blackPrimary,
                                body: FullScreenVLC(
                                  controller: controller,
                                  url:
                                      'https://iothub.gps.id/media/live/$imei.flv',
                                  limit: limit.toString(),
                                  camera: camera.toString(),
                                  imei: imei,
                                  file: file,
                                  darkMode: darkMode,
                                ),
                              ),
                              type: PageTransitionType.fade,
                            ));
                          },
                        )
                      ],
                    )
                  ],
                )),
          );
        },
      );
    },
  );
}

vlcPLayerFullScreen(BuildContext context, VlcPlayerController controller,
    String url, String limit, String camera, String imei, String file) async {
  // String time = '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // return alert;
      String _printDurationII(Duration duration) {
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        return " ${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
      }

      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          controller = VlcPlayerController.network(url,
              autoInitialize: true, autoPlay: true);
          controller.addListener(() {
            // time = controller.value.position.inSeconds.toString();
            if (controller.value.position.inSeconds == 1) {}
            if (controller.value.isEnded) {
              print('isEnded');
            }
          });

          return Dialog(
            backgroundColor: blackPrimary,
            insetPadding: const EdgeInsets.all(1),
            alignment: Alignment.center,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: VlcPlayer(
                      controller: controller,
                      aspectRatio: 100 / 100,
                      // aspectRatio: (MediaQuery.of(context).size.width) /
                      //     (MediaQuery.of(context).size.height),
                      placeholder: Container(
                        color: blackPrimary,
                        child: const Center(child: CircularProgressIndicator()),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icon/dashcam/redDot.png',
                            width: 8,
                            height: 8,
                          ),
                          Text(
                            // 'Limit Stream : ${_printDurationII(Duration(seconds: widget.limit))} / $_refreshLabelDashcam',
                            'Limit Stream : ${_printDurationII(Duration(seconds: int.parse(limit)))}',
                            style: reguler.copyWith(
                                color: whiteColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        controller.dispose();
                        Navigator.pop(context);
                        SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.portraitUp]);
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

showInfoAlert(BuildContext context, String msg, String sub) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.error_outline_outlined,
              size: 33.0,
              color: blackPrimary,
            ),
          ),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: reguler.copyWith(
              color: blackPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: reguler.copyWith(color: blackPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

accountDeletedAlert(BuildContext context, String msg, String sub) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.error_outline_outlined,
              size: 33.0,
              color: blackPrimary,
            ),
          ),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: reguler.copyWith(
              color: blackPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: reguler.copyWith(color: blackPrimary, fontSize: 12),
            ),
          ),
          GestureDetector(
            child: Image.asset(
              'assets/whatsapp.png',
              width: 100,
            ),
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                isDismissible: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                backgroundColor: whiteCardColor,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context)!.needHelp,
                                        style: bold.copyWith(
                                            fontSize: 16, color: blackPrimary)),
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
                                  style: reguler.copyWith(
                                      fontSize: 10, color: blackSecondary3),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                            // InkWell(
                            //   enableFeedback:
                            //       url.data.branch.whatsapp == '' ? false : true,
                            //   onTap: () {
                            //     if (url.data.branch.whatsapp != '') {
                            //       launchUrl(
                            //           Uri.parse(
                            //               'https://wa.me/${url.data.branch.whatsapp}'),
                            //           mode: LaunchMode.externalApplication);
                            //       Navigator.pop(context);
                            //     }
                            //     // url.data.branch.whatsapp == '' ? {} : launchUrl(Uri.parse('https://wa.me/${url.data.branch.whatsapp}'), mode: LaunchMode.externalApplication);
                            //   },
                            //   child: Padding(
                            //     padding:
                            //         const EdgeInsets.only(top: 10, bottom: 5),
                            //     child: Container(
                            //       width: double.infinity,
                            //       decoration: BoxDecoration(
                            //         color: whiteColor,
                            //         // color: all ? blueGradient : whiteColor,
                            //         borderRadius: BorderRadius.circular(8),
                            //         border: Border.all(
                            //           width: 1,
                            //           color: url.data.branch.whatsapp == ''
                            //               ? greyColor
                            //               : greenPrimary,
                            //         ),
                            //       ),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Padding(
                            //             padding: const EdgeInsets.all(12),
                            //             child: Row(
                            //               children: [
                            //                 // Icon(
                            //                 //   Icons.whatsapp_outlined,
                            //                 //   color: url.data.branch.whatsapp == '' ? greyColor : greenPrimary,
                            //                 //   size: 15,
                            //                 // ),
                            //                 Padding(
                            //                   padding: const EdgeInsets.only(
                            //                       left: 2),
                            //                   child: Row(
                            //                     children: [
                            //                       Padding(
                            //                         padding: const EdgeInsets
                            //                             .symmetric(
                            //                             horizontal: 5),
                            //                         child: Image.asset(
                            //                             'assets/wa2.png',
                            //                             width: 18,
                            //                             height: 18,
                            //                             color: widget.darkMode
                            //                                 ? null
                            //                                 : greyColor),
                            //                       ),
                            //                       Text(
                            //                           AppLocalizations.of(
                            //                                   context)!
                            //                               .installationBranch,
                            //                           style: bold.copyWith(
                            //                               fontSize: 12,
                            //                               color: url.data.branch
                            //                                           .whatsapp ==
                            //                                       ''
                            //                                   ? greyColor
                            //                                   : greenPrimary)),
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            InkWell(
                              onTap: () {
                                // 'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'
                                launchUrl(
                                    Uri.parse('https://wa.me/628111877333'),
                                    mode: LaunchMode.externalApplication);
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
                                              padding: const EdgeInsets.only(
                                                  left: 2),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    child: Image.asset(
                                                      'assets/wa2.png',
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .cc24H,
                                                      style: bold.copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              whiteColorDarkMode)),
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
    ),
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showSuccessRegister(BuildContext context, String msg, String sub) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 335,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            msg,
            textAlign: TextAlign.center,
            style: bold.copyWith(color: blackPrimary, fontSize: 16),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image.asset(
                'assets/handling/successregister.png',
                height: 160,
                width: 160,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: reguler.copyWith(color: blackPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showUpdateAlert(BuildContext context, String msg, String sub) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.system_update_outlined,
              size: 33.0,
              color: Color(0xffcacaca),
            ),
          ),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: reguler.copyWith(
              color: blackPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: reguler.copyWith(color: blackPrimary, fontSize: 12),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 20),
          //   child: InkWell(
          //     onTap: () {
          //       print(Uri.parse(
          //           'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'));
          //       launchUrl(
          //           Uri.parse(
          //               'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'),
          //           mode: LaunchMode.externalApplication);
          //       Navigator.pop(context);
          //     },
          //     child: Image.asset(
          //       'assets/whatsapp.png',
          //       width: 100,
          //     ),
          //   ),
          // )
        ],
      ),
    ),
    actions: [
      Row(
        children: [
          Flexible(
            flex: 1,
            child: _updateNow(context),
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            flex: 1,
            child: _updateLater(context),
          )
        ],
      )
    ],
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

lostAlert(BuildContext context, String username, String title, String subtitle,
    String imei, String plat) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.error_outline_outlined,
              size: 33.0,
              color: Color(0xffcacaca),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: reguler.copyWith(
              color: blackPrimary,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: reguler.copyWith(color: blackPrimary, fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () async {
                print(Uri.parse(
                    'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'));
                // launchUrl(
                //     Uri.parse(
                //         'https://wa.me/628111877333?text=Halo%20GPS.id,%0A%0AKendaraan%20saya%20dengan:%0A%0AIMEI:%20$imei%0APlat:%20$plat%0A%0ATidak%20update,%20mohon%20diperiksa'),
                //     mode: LaunchMode.externalApplication);
                // Dialogs().loadingDialog(context);
                LinkModel url = await GeneralService().readLocalUrl();
                // Dialogs().hideLoaderDialog(context);
                Navigator.pop(context);
                showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .needHelp,
                                          style: bold.copyWith(
                                              fontSize: 16,
                                              color: blackPrimary)),
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
                                          child: const Icon(
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
                                    AppLocalizations.of(context)!.needHelpSub,
                                    style: reguler.copyWith(
                                        fontSize: 10, color: blackSecondary3),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                              InkWell(
                                enableFeedback: url.data.branch.whatsapp == ''
                                    ? false
                                    : true,
                                onTap: () {
                                  if (url.data.branch.whatsapp != '') {
                                    launchUrl(
                                        Uri.parse(
                                            'https://wa.me/${url.data.branch.whatsapp}?text=Halo%20SUPERSPRING%2C%20%0A%0Asaya%20pengguna%20GPS.id%20dengan%20username%20$username.%20Saya%20sedang%20mengalami%20kendala%20saat%20mengakses%20informasi%20kendaraan%20dengan%20plat%20nomor%20$plat.%20Mohon%20dibantu%20untuk%20pengecekan%20lebih%20lanjut.'),
                                        mode: LaunchMode.externalApplication);
                                    Navigator.pop(context);
                                  }
                                  // url.data.branch.whatsapp == ''
                                  //     ? {}
                                  //     : launchUrl(
                                  //         Uri.parse(
                                  //             'https://wa.me/${url.data.branch.whatsapp}?text=Halo%20SUPERSPRING%2C%20%0A%0Asaya%20pengguna%20GPS.id%20dengan%20username%20$username.%20Saya%20sedang%20mengalami%20kendala%20saat%20mengakses%20informasi%20kendaraan%20dengan%20plat%20nomor%20$plat.%20Mohon%20dibantu%20untuk%20pengecekan%20lebih%20lanjut.'),
                                  //         mode: LaunchMode.externalApplication);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 5),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      // color: all ? blueGradient : whiteColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color: url.data.branch.whatsapp == ''
                                            ? greyColor
                                            : greenPrimary,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // Icon(
                                              //   Icons.whatsapp_outlined,
                                              //   color:
                                              //       url.data.branch.whatsapp ==
                                              //               ''
                                              //           ? greyColor
                                              //           : greenPrimary,
                                              //   size: 15,
                                              // ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2),
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .installationBranch,
                                                    style: bold.copyWith(
                                                        fontSize: 12,
                                                        color: url.data.branch
                                                                    .whatsapp ==
                                                                ''
                                                            ? greyColor
                                                            : greenPrimary)),
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
                                          'https://wa.me/${url.data.head.whatsapp}?text=Halo%20SUPERSPRING%2C%20%0A%0Asaya%20pengguna%20GPS.id%20dengan%20username%20$username.%20Saya%20sedang%20mengalami%20kendala%20saat%20mengakses%20informasi%20kendaraan%20dengan%20plat%20nomor%20$plat.%20Mohon%20dibantu%20untuk%20pengecekan%20lebih%20lanjut.'),
                                      mode: LaunchMode.externalApplication);
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                padding: const EdgeInsets.only(
                                                    left: 2),
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
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
                'assets/whatsapp.png',
                width: 100,
              ),
            ),
          )
        ],
      ),
    ),
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

redeemDialog(BuildContext context, int id, String desc, String currPoint,
    String rewardPoin, int rewardId) {
  TextEditingController note = TextEditingController();
  String text = '';
  AlertDialog alert = AlertDialog(
    content: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Icon(
              Icons.error_outline_outlined,
              size: 40.0,
              color: Color(0xffcacaca),
            ),
          ),
          Text(
            note.text,
            textAlign: TextAlign.center,
            style: reguler.copyWith(color: blackPrimary),
          ),
          Text(
            '${AppLocalizations.of(context)!.redeemSSPoin1} $desc ?',
            textAlign: TextAlign.center,
            style: reguler.copyWith(color: blackPrimary),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: Text(
              '${AppLocalizations.of(context)!.redeemSSPoin2} $rewardPoin SSPoin',
              textAlign: TextAlign.center,
              style: reguler.copyWith(
                  color: const Color(0xff808080), fontSize: 14),
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   decoration: BoxDecoration(border: Border.all(width: 1), shape: Round),
          //   child: TextFormField(
          //     controller: note,
          //     onChanged: (value) {
          //       text = value;
          //     },
          //   ),
          // ),
          Visibility(
              visible: rewardId == 11 ? false : true,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  controller: note,
                  onChanged: (value) {
                    text = value;
                  },
                  style: reguler.copyWith(
                    fontSize: 13,
                    color: blackPrimary,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    fillColor: whiteCardColor,
                    // errorText: wrongUsernamePassword
                    //     ? 'Username or password not registered'
                    //     : '',
                    filled: true,
                    hintText: AppLocalizations.of(context)!.redeemNote,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: blackSecondary3,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: bluePrimary,
                      ),
                    ),
                    hintStyle: reguler.copyWith(
                      fontSize: 12,
                      color: blackSecondary3,
                    ),
                    // contentPadding: const EdgeInsets.symmetric(
                    //   vertical: 12,
                    //   horizontal: 20,
                    // ),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: yellowSecondary,
                            border: Border.all(color: yellowSecondary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: yellowPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  // flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () async {
                        rewardId == 11
                            ? redeemPoint(context, id, ' ')
                            : redeemPoint(context, id, text);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: greenSecondary,
                            border: Border.all(color: greenSecondary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.redeemPoin,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: greenPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //     padding: const EdgeInsets.only(
          //       top: 20,
          //     ),
          //     child: TextFormField(
          //       controller: note,
          //     )
          //     // Text(
          //     //   '${AppLocalizations.of(context)!.redeemSSPoin2} $rewardPoin SSPoin',
          //     //   textAlign: TextAlign.center,
          //     //   style: reguler.copyWith(color: Color(0xff808080), fontSize: 14),
          //     // ),
          //     ),
        ],
      ),
    ),
    // actions: [
    //   Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Flexible(
    //         flex: 1,
    //         child: Padding(
    //           padding: const EdgeInsets.all(12.0),
    //           child: InkWell(
    //             onTap: () {
    //               Navigator.pop(context);
    //             },
    //             child: Container(
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                   color: yellowSecondary,
    //                   border: Border.all(color: yellowSecondary),
    //                   borderRadius:
    //                       const BorderRadius.all(Radius.circular(12))),
    //               child: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Text(
    //                   AppLocalizations.of(context)!.cancel,
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                     color: yellowPrimary,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Flexible(
    //         flex: 1,
    //         child: Padding(
    //           padding: const EdgeInsets.all(12.0),
    //           child: InkWell(
    //             onTap: () async {
    //               redeemPoint(context, id, text);
    //             },
    //             child: Container(
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                   color: greenSecondary,
    //                   border: Border.all(color: greenSecondary),
    //                   borderRadius:
    //                       const BorderRadius.all(Radius.circular(12))),
    //               child: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Text(
    //                   AppLocalizations.of(context)!.redeemPoin,
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                     color: greenPrimary,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ],
    backgroundColor: whiteColor,
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showQR(BuildContext context, String url) {
  AlertDialog alert = AlertDialog(
    title: const Align(
      alignment: Alignment.center,
      child: Text('Scan QR'),
    ),
    content:
        // Text(
        //   msg,
        //   textAlign: TextAlign.center,
        // ),
        Image.network(url),
    actionsPadding: const EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 1,
            child: _closePopButton(context),
          ),
          // SizedBox(
          //   width: 10.0,
          // ),
          // Flexible(
          //   flex: 1,
          //   child: _closeButton(context),
          // ),
        ],
      ),
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showSuccess(BuildContext context, String msg) {
  AlertDialog alert = AlertDialog(
    title: const Icon(
      Icons.check_circle_outlined,
      size: 64.0,
      color: Colors.green,
    ),
    backgroundColor: whiteColor,
    content: Text(
      msg,
      textAlign: TextAlign.center,
      style: reguler.copyWith(color: blackPrimary),
    ),
    actionsPadding: const EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 1,
            child: _closePopButtonSuccess(context),
          ),
          // SizedBox(
          //   width: 10.0,
          // ),
          // Flexible(
          //   flex: 1,
          //   child: _closeButton(context),
          // ),
        ],
      ),
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showSuccessEditProfile(BuildContext context, String msg) {
  AlertDialog alert = AlertDialog(
    backgroundColor: whiteCardColor,
    title: Icon(
      Icons.check_circle_outlined,
      size: 64.0,
      color: greenPrimary,
    ),
    content: Text(
      msg,
      style: reguler.copyWith(color: blackPrimary, fontSize: 12),
      textAlign: TextAlign.center,
    ),
    actionsPadding: const EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 1,
            child: _closePopButtonSuccessEditProfile(context),
          ),
          // SizedBox(
          //   width: 10.0,
          // ),
          // Flexible(
          //   flex: 1,
          //   child: _closeButton(context),
          // ),
        ],
      ),
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showInfo(BuildContext context) {
  AlertDialog alert = AlertDialog(
    // title: const Icon(
    //   Icons.error_outline_outlined,
    //   size: 64.0,
    //   color: Colors.orange,
    // ),
    content: Column(
      children: [
        Image.asset('assets/noData.png'),
        const Text(
          'Maaf, pencarian tidak dapat ditemukan',
          textAlign: TextAlign.center,
        ),
        const Text(
          'Coba masukan karakter lainnya,',
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actionsPadding: const EdgeInsets.symmetric(
      horizontal: 10.0,
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 1,
            child: _closePopButton(context),
          ),
          // SizedBox(
          //   width: 10.0,
          // ),
          // Flexible(
          //   flex: 1,
          //   child: _closeButton(context),
          // ),
        ],
      ),
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
