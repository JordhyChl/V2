// ignore_for_file: use_build_context_synchronously, avoid_print, file_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/dialog.dart';
import 'package:gpsid/theme.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class VlcPlayerTest extends StatefulWidget {
  final VlcPlayerController controller;
  final String url;
  final String limit;
  final String camera;
  final String imei;
  final String file;
  const VlcPlayerTest(
      {super.key,
      required this.controller,
      required this.url,
      required this.limit,
      required this.camera,
      required this.imei,
      required this.file});

  @override
  State<VlcPlayerTest> createState() => _VlcPlayerTestState();
}

class _VlcPlayerTestState extends State<VlcPlayerTest> {
  late VlcPlayerController controller;
  String startTime = '';
  String time = '';

  @override
  void initState() {
    controller = VlcPlayerController.network(widget.url,
        autoInitialize: true, autoPlay: true);
    controller.addListener(() {
      time = controller.value.position.inSeconds.toString();
      // time = controller.value.position.inSeconds.toString();
      if (controller.value.position.inSeconds == 1) {
        startTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toLocal());
      }
      if (controller.value.isEnded) {
        print('isEnded');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Dialog(
      backgroundColor: blackPrimary,
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
                          'Limit Stream : ${widget.limit}',
                          style:
                              reguler.copyWith(color: whiteColor, fontSize: 10),
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
                        widget.camera;
                        time;
                        startTime;
                        String finishTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(DateTime.parse(startTime)
                                .add(Duration(seconds: int.parse(time))));
                        final result = await APIService().storeLimit(
                            startTime,
                            finishTime.toString(),
                            controller.value.position.inSeconds.toString(),
                            widget.imei,
                            action,
                            widget.camera,
                            widget.file);
                        if (result is MessageModel) {
                          Dialogs().hideLoaderDialog(context);
                          showInfoAlert(context, result.message, '');
                        } else {
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
                      color: whiteColor,
                    ),
                  ),
                ],
              ),
              VlcPlayer(
                  controller: controller,
                  aspectRatio: 16 / 9,
                  placeholder: Container(
                    color: blackPrimary,
                    child: const Center(child: CircularProgressIndicator()),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      if (controller.value.isPlaying) {
                        controller.pause();
                        Dialogs().loadingDialog(context);
                        String action = '2';
                        widget.camera;
                        time;
                        startTime;
                        String finishTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(DateTime.parse(startTime)
                                .add(Duration(seconds: int.parse(time))));
                        final result = await APIService().storeLimit(
                            startTime,
                            finishTime.toString(),
                            controller.value.position.inSeconds.toString(),
                            widget.imei,
                            action,
                            widget.camera,
                            widget.file);
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
                      setState(() {});
                    },
                    child: Image.asset(
                      controller.value.isPlaying
                          ? 'assets/icon/dashcam/pause.png'
                          : 'assets/icon/dashcam/play.png',
                      // cam == 0
                      //     ? videoPlayerController0.value.isPlaying
                      //         ? 'assets/icon/dashcam/pause.png'
                      //         : 'assets/icon/dashcam/play.png'
                      //     : videoPlayerController1.value.isPlaying
                      //         ? 'assets/icon/dashcam/pause.png'
                      //         : 'assets/icon/dashcam/play.png',
                      width: 25,
                      height: 25,
                      color: whiteColor,
                      // color: cam == 0
                      //     ? isPlaying
                      //         ? blueGradientSecondary2
                      //         : greyColor
                      //     : isPlaying1
                      //         ? blueGradientSecondary2
                      //         : greyColor,
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
                        final result = await ImageGallerySaver.saveImage(bytes,
                            name: name);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Image saved to gallery"),
                          backgroundColor: blueGradient,
                        ));
                        return Platform.isAndroid ? result['filePath'] : '';
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
                        color: whiteColor,
                      ),
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }
}
