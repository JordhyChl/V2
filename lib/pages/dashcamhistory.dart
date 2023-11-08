// ignore_for_file: use_build_context_synchronously, must_be_immutable, unused_field, unused_local_variable, unnecessary_null_comparison, avoid_print, prefer_final_fields

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/checklimit.model.dart';
import 'package:gpsid/model/commandlivestream.model.dart';
import 'package:gpsid/model/dashcamhistory.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DashcamHistory extends StatefulWidget {
  final String imei;
  final String deviceName;
  final String date;
  final bool darkMode;
  int limit;
  final int totalCamera;
  DashcamHistory(
      {super.key,
      required this.imei,
      required this.deviceName,
      required this.limit,
      required this.date,
      required this.totalCamera,
      required this.darkMode});

  @override
  State<DashcamHistory> createState() => _DashcamHistoryState();
}

class _DashcamHistoryState extends State<DashcamHistory> {
  VlcPlayerController videoPlayerController0 = VlcPlayerController.network('',
      autoPlay: false,
      autoInitialize: true,
      hwAcc: HwAcc.auto,
      options: VlcPlayerOptions());
  late Future<dynamic> _getVideoPlayer0;
  // late VideoPlayerController videoPlayerController0;
  late Future<dynamic> _getVLC;
  // late VlcPlayerController videoPlayerController1;
  late bool isPlay0;
  late bool isPlay1;
  int cam = 1;
  int histCam = 1;
  TextEditingController startDateController = TextEditingController();
  int selected = 0;
  bool selectPhoto = true;
  String position = '';
  String duration = '';
  bool validPosition = false;
  double sliderValue = 0.0;
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;
  DateTime lastRecordingShowTime = DateTime.now();
  double recordingTextOpacity = 0;
  bool isRecording = false;
  bool isBuffering = true;
  String getDate = '';
  bool changeDate = false;
  String _refreshLabelDashcam = '0';
  String startTime = '';
  int limit = 0;

  List<dynamic> historyCam1 = [];
  List<dynamic> historyCam2 = [];

  @override
  void initState() {
    super.initState();
    _getVideoPlayer0 = getVideoPlayer0();
    startDateController.text =
        DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(widget.date));
  }

  @override
  void dispose() async {
    super.dispose();
    // Dialogs().loadingDialog(context);
    // final result =
    //     await APIService().liveStreamDashcam(widget.imei, 'RTMP,OFF,INOUT');
    // if (result is CommandDashcam) {
    //   // Dialogs().hideLoaderDialog(context);
    //   // Navigator.pop(context);
    // } else {
    //   // Dialogs().hideLoaderDialog(context);
    //   showInfoAlert(context, result.statusError, '');
    // }
    // if (mounted) {
    //   videoPlayerController0.dispose();
    // }
    // String action = '1';
    // cam;
    // _refreshLabelDashcam;
    // startTime;
    // String finishTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
    //     DateTime.parse(startTime)
    //         .add(Duration(seconds: int.parse(_refreshLabelDashcam))));
    // final storeReplay = await APIService().storeLimit(
    //     startTime,
    //     finishTime.toString(),
    //     _refreshLabelDashcam,
    //     widget.imei,
    //     action,
    //     cam.toString(),
    //     'RTMP,ON,INOUT');
    // if (result is MessageModel) {
    //   showInfoAlert(context, storeReplay.message, '');
    // }

    ////////
    // _timer.isActive ? _timer.cancel() : {};
    // _timerDashcam.isActive ? _timerDashcam.cancel() : {};
  }

  String _printDurationII(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'SS_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Image saved to gallery"),
      backgroundColor: blueGradient,
    ));
    return Platform.isAndroid ? result['filePath'] : '';
  }

  command(int index) async {
    Dialogs().loadingDialog(context);
    final result = await APIService().liveStreamDashcam(
        widget.imei,
        // 'REPLAYLIST,${testHistory.data.filelistCamera1.listFile[0].file}');
        'REPLAYLIST,${histCam == 1 ? historyCam1[index].file : historyCam2[index].file}');
    if (result is CommandDashcam) {
      if (result.data.content == 'OK!') {
        final limitResult = await APIService().checkLimit(widget.imei,
            'REPLAYLIST,${histCam == 1 ? historyCam1[index].file : historyCam2[index].file}');
        if (limitResult is CheckLimitModel) {
          if (limitResult.status) {
            setState(() {
              limit = limitResult.data.limitLive;
            });

            if (limitResult.data.limitLive == 0) {
              Dialogs().hideLoaderDialog(context);
              showInfoAlert(context, 'Your limit is up, Please Top up', '');
            } else {
              Dialogs().hideLoaderDialog(context);
              vlcPLayer(
                  context,
                  videoPlayerController0,
                  'https://iothub.gps.id/media/live/${widget.imei}.flv',
                  // _printDurationII(
                  //     Duration(seconds: limitResult.data.limitLive)),
                  limit.toString(),
                  histCam == 1 ? '0' : '1',
                  widget.imei,
                  'REPLAYLIST,${histCam == 1 ? historyCam1[index].file : historyCam2[index].file}',
                  widget.darkMode);
            }
          } else {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(context, limitResult.message, '');
          }
        } else {
          if (limitResult is MessageModel) {
            Dialogs().hideLoaderDialog(context);
            // showInfoAlert(context, limitResult.message, '');
            showInfoAlert(
                context,
                limitResult.message ==
                        'Unable to load data, Please wait and refresh this page.'
                    ? AppLocalizations.of(context)!.errorPushing
                    : limitResult.message ==
                            'Your device is currently busy, Please wait and refresh this page.'
                        ? AppLocalizations.of(context)!.errorBusy
                        : limitResult.message,
                limitResult.message ==
                        'Unable to load data, Please wait and refresh this page.'
                    ? AppLocalizations.of(context)!.errorPushingSub
                    : limitResult.message ==
                            'Your device is currently busy, Please wait and refresh this page.'
                        ? AppLocalizations.of(context)!.errorPushingSub
                        : '');
          }
        }
      } else {
        // Dialogs().hideLoaderDialog(context);
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(
            context,
            result.msg == 'live streaming pushing, can not executed'
                ? AppLocalizations.of(context)!.errorPushing
                : result.msg ==
                        'Device busy (previous command has not returned)'
                    ? AppLocalizations.of(context)!.errorBusy
                    : result.msg,
            result.msg == 'live streaming pushing, can not executed'
                ? AppLocalizations.of(context)!.errorPushingSub
                : result.msg ==
                        'Device busy (previous command has not returned)'
                    ? AppLocalizations.of(context)!.errorBusySub
                    : '');
        // _getVideoPlayer0 = getVideoPlayer0();
      }
    } else {
      // Dialogs().hideLoaderDialog(context);
      Dialogs().hideLoaderDialog(context);
      // showInfoAlert(
      //     context,
      //     result.data.code == '600' || result.data.code == '302'
      //         ? result.data.msg == 'Failed to respond for more than one minute'
      //             ? 'more than 1 minute'
      //             : result.data.msg ==
      //                     'live streaming pushing, can not executed'
      //                 ? 'pushing pushing'
      //                 : result.data.msg ==
      //                         'Device busy (previous command has not returned)'
      //                     ? 'busy busy'
      //                     : result.data.msg
      //         : result.statusError,
      //     '');
      showInfoAlert(
          context,
          result.data.code == '600' || result.data.code == '302'
              ? result.data.msg
              : result.statusError,
          '');
      // _getVideoPlayer0 = getVideoPlayer0();
    }
  }

  Future<dynamic> getVideoPlayer0() async {
    if (changeDate) {
      Dialogs().loadingDialog(context);
      final history = await APIService().dashcamHistory(widget.imei, getDate);
      if (history is DashcamHistoryModel) {
        setState(() {
          historyCam1 = history.dataDashcamHist.filelistCamera1.listFile;
          historyCam2 = history.dataDashcamHist.filelistCamera2.listFile;
        });
        Dialogs().hideLoaderDialog(context);

        // final result = await APIService().liveStreamDashcam(
        //     widget.imei,
        //     // 'REPLAYLIST,${testHistory.data.filelistCamera1.listFile[0].file}');
        //     'REPLAYLIST,${historyCam1[0].file}');
        // if (result is CommandDashcam) {
        //   if (result.data.content == 'OK!') {
        //     Dialogs().hideLoaderDialog(context);
        //   } else {
        //     Dialogs().hideLoaderDialog(context);
        //     showInfoAlert(context, result.data.content, '');
        //     _getVideoPlayer0 = getVideoPlayer0();
        //   }
        // } else {
        //   Dialogs().hideLoaderDialog(context);
        //   showInfoAlert(context, result.statusError, '');
        //   _getVideoPlayer0 = getVideoPlayer0();
        // }
        return history;
        // history.addAll([testHistory.data.file])
      } else if (history is MessageModel) {
        Dialogs().hideLoaderDialog(context);
        setState(() {
          historyCam1.clear();
          historyCam2.clear();
        });

        showInfoAlert(
            context, history.message.toString(), history.status.toString());
      }
      print(history);
    } else {
      final res = await APIService()
          .liveStreamDashcamCommand(widget.imei, 'RTMP,OFF,INOUT');
      if (res is CommandDashcam) {
        if (res.data.content != 'OK!') {
          showInfoAlert(context, res.data.content, '');
        } else {
          Dialogs().loadingDialog(context);
          String yesterday = '';
          yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
          final history =
              await APIService().dashcamHistory(widget.imei, widget.date);
          if (history is DashcamHistoryModel) {
            Dialogs().hideLoaderDialog(context);
            setState(() {
              historyCam1 = history.dataDashcamHist.filelistCamera1.listFile;
              historyCam2 = history.dataDashcamHist.filelistCamera2.listFile;
            });
            return history;
          } else if (history is MessageModel) {
            Dialogs().hideLoaderDialog(context);
            showInfoAlert(
                context, history.message.toString(), history.status.toString());
          }
        }
      } else {
        showInfoAlert(
            context,
            res.data.code == '600' || res.data.code == '302'
                ? res.data.msg
                : res.statusError,
            '');
      }
    }
  }

  void listener() async {
    if (!mounted) return;
    //
    if (videoPlayerController0.value.isInitialized) {
      var oPosition = videoPlayerController0.value.position;
      var oDuration = videoPlayerController0.value.duration;
      if (oPosition != null && oDuration != null) {
        if (oDuration.inHours == 0) {
          var strPosition = oPosition.toString().split('.')[0];
          var strDuration = oDuration.toString().split('.')[0];
          position =
              "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          duration =
              "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
        } else {
          position = oPosition.toString().split('.')[0];
          duration = oDuration.toString().split('.')[0];
        }
        validPosition = oDuration.compareTo(oPosition) >= 0;
        sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      }
      setState(() {});
    }
  }

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().toLocal(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now().subtract(const Duration(days: 365)).toLocal(),
        lastDate: DateTime.now().toLocal());
    if (picked != null) {
      setState(() {
        startDateController.text =
            DateFormat('EEEE, dd MMM yyyy').format(picked);
        getDate = DateFormat('yyyy-MM-dd').format(picked);
        changeDate = true;
        _getVideoPlayer0 = getVideoPlayer0();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
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
          title: Stack(
            children: [
              InkWell(
                // onTap: () => Navigator.pop(context),
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'History',
                        style: bold.copyWith(
                          fontSize: 14,
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                        ),
                      ),
                      Text(
                        widget.deviceName,
                        style: bold.copyWith(
                          fontSize: 10,
                          color:
                              widget.darkMode ? whiteColorDarkMode : whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),
      body: Column(
        children: [
          SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: InkWell(
                      onTap: () {
                        print(videoPlayerController0.value.playingState.name ==
                            'stoped');
                      },
                      child: Text(
                        'Tanggal',
                        style: bold.copyWith(color: blackPrimary, fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    // padding: const EdgeInsets.only(left: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          // width: 283,
                          // height: 40,
                          flex: 3,
                          child: InkWell(
                            onTap: () => _selectStartDate(context),
                            child: TextField(
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              enabled: false,
                              style: reguler.copyWith(
                                  color: blackPrimary, fontSize: 12),
                              controller: startDateController,
                              decoration: InputDecoration(
                                disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: blueGradientSecondary2)),
                                fillColor: whiteCardColor,
                                filled: true,
                                hintText: AppLocalizations.of(context)!
                                    .insertStartDate,
                                hintStyle: reguler.copyWith(
                                  fontSize: 10,
                                  color: blackSecondary3,
                                ),
                                contentPadding: const EdgeInsets.only(
                                  bottom: 10,
                                  left: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: Text(
                      'Timeline',
                      style: bold.copyWith(color: blackPrimary, fontSize: 16),
                    ),
                  ),
                  Visibility(
                    visible: widget.totalCamera == 2 ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 8, bottom: 10),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: whiteCardColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: histCam == 1
                                        ? bluePrimary
                                        : whiteCardColor,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    side: BorderSide(
                                        width: 1, color: bluePrimary)),
                                onPressed: () async {
                                  setState(() {
                                    histCam = 1;
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    'Cam 1',
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: histCam == 1
                                            ? widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteColor
                                            : bluePrimary),
                                  ),
                                ),
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: histCam == 1
                                        ? whiteCardColor
                                        : bluePrimary,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    side: BorderSide(
                                        width: 1,
                                        style: BorderStyle.solid,
                                        color: bluePrimary)),
                                onPressed: () async {
                                  setState(() {
                                    histCam = 2;
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    'Cam 2',
                                    style: reguler.copyWith(
                                        fontSize: 12,
                                        color: histCam == 1
                                            ? bluePrimary
                                            : widget.darkMode
                                                ? whiteColorDarkMode
                                                : whiteColor),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
          Expanded(
            //disini jangan lupa
            child: histCam == 1
                ? historyCam1.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 50, right: 50, top: 10),
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .runningreportEmpty,
                                  textAlign: TextAlign.center,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: widget.darkMode
                                        ? whiteColorDarkMode
                                        : blackSecondary2,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30, right: 30, top: 10),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .runningreportEmptySub,
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
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: historyCam1.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: whiteColor,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7))),
                                  side: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: selected == index
                                          ? bluePrimary
                                          : greyColor)),
                              onPressed: () async {
                                // setState(() {
                                //   histCam = 2;
                                // });
                                setState(() {
                                  selected = index;
                                });
                                command(index);
                                // setDashcamHist(index);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            width: 1,
                                            color: selected == index
                                                ? bluePrimary
                                                : greyColor,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: selected == index
                                                  ? bluePrimary
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // '15:1$index:0$index',
                                      historyCam1[index].time,
                                      style: reguler.copyWith(
                                          fontSize: 14,
                                          color: selected == index
                                              ? bluePrimary
                                              : blackPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: historyCam2.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: whiteColor,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7))),
                              side: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: greyColor)),
                          onPressed: () async {
                            // setState(() {
                            //   histCam = 2;
                            // });
                            setState(() {
                              selected = index;
                            });
                            command(index);
                            // setDashcamHist(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        width: 1,
                                        color: selected == index
                                            ? bluePrimary
                                            : greyColor,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: selected == index
                                              ? bluePrimary
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  // '15:1$index:0$index',
                                  historyCam2[index].time,
                                  style: reguler.copyWith(
                                      fontSize: 14, color: blackPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visibility(
                //     visible: true,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           _printDurationII(Duration(seconds: limit)),
                //           style: reguler.copyWith(
                //               color: blackPrimary, fontSize: 12),
                //         )
                //       ],
                //     )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: redPrimary,
                    ),
                    Text(
                      ' Limit Stream : ',
                      style:
                          reguler.copyWith(color: blackPrimary, fontSize: 12),
                    ),
                    Text(_printDurationII(Duration(seconds: limit)),
                        style: reguler.copyWith(
                            color: blackPrimary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
