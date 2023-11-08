// ignore_for_file: must_be_immutable, avoid_print, unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';

class FullScreenVLC extends StatefulWidget {
  VlcPlayerController controller;
  final String url;
  final String limit;
  final String camera;
  final String imei;
  final String file;
  final bool darkMode;
  FullScreenVLC(
      {super.key,
      required this.controller,
      required this.url,
      required this.limit,
      required this.camera,
      required this.imei,
      required this.file,
      required this.darkMode});

  @override
  State<FullScreenVLC> createState() => _FullScreenVLCState();
}

class _FullScreenVLCState extends State<FullScreenVLC> {
  String time = '';
  String startTime = '';

  String _printDurationII(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return " ${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      Platform.isIOS
          ? DeviceOrientation.landscapeRight
          : DeviceOrientation.landscapeLeft
    ]);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        widget.controller = VlcPlayerController.network(widget.url,
            autoInitialize: true, autoPlay: true);
        widget.controller.addListener(() {
          time = widget.controller.value.position.inSeconds.toString();
          // time = controller.value.position.inSeconds.toString();
          if (widget.controller.value.position.inSeconds == 1) {
            startTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.now().toLocal());
          }
          if (widget.controller.value.isEnded) {
            print('isEnded');
          }
        });

        return Dialog(
          backgroundColor: widget.darkMode ? whiteColorDarkMode : blackPrimary,
          insetPadding: const EdgeInsets.all(1),
          alignment: Alignment.center,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: VlcPlayer(
                    controller: widget.controller,
                    aspectRatio: 16 / 9,
                    // aspectRatio: (MediaQuery.of(context).size.width) /
                    //     (MediaQuery.of(context).size.height),
                    placeholder: Container(
                      color: widget.darkMode ? whiteCardColor : blackPrimary,
                      child: const Center(child: CircularProgressIndicator()),
                    )),
              ),
              Positioned(
                  top: 12,
                  right: 10,
                  child: InkWell(
                    onTap: () async {
                      widget.controller.dispose();
                      Navigator.pop(context);
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp]);
                    },
                    child: Icon(
                      Icons.close,
                      size: 30,
                      color: widget.darkMode ? whiteColorDarkMode : whiteColor,
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
