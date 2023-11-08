// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:gpsid/common.dart';
// import 'package:gpsid/model/errortrap.model.dart';
// import 'package:gpsid/model/message.model.dart';
// import 'package:gpsid/pages/dashcamhistory.dart';
// import 'package:gpsid/service/api.dart';
// import 'package:gpsid/theme.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

// class DashcamSample extends StatefulWidget {
//   final String imei;
//   final String vehName;
//   const DashcamSample({super.key, required this.imei, required this.vehName});

//   @override
//   State<DashcamSample> createState() => _DashcamSampleState();
// }

// class _DashcamSampleState extends State<DashcamSample> {
//   late VideoPlayerController videoPlayerController0;
//   late Future<dynamic> _getVLC;
//   // late VlcPlayerController videoPlayerController1;
//   late bool isPlay0;
//   late bool isPlay1;
//   int cam = 1;
//   int histCam = 1;
//   TextEditingController startDateController = TextEditingController();
//   int selected = 0;
//   bool selectPhoto = true;
//   String position = '';
//   String duration = '';
//   bool validPosition = false;
//   double sliderValue = 0.0;
//   int numberOfCaptions = 0;
//   int numberOfAudioTracks = 0;
//   DateTime lastRecordingShowTime = DateTime.now();
//   double recordingTextOpacity = 0;
//   bool isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     setLiveStream('0');
//     videoPlayerController0 = VideoPlayerController.network(
//         'https://api-apps.gps.id/media/live/0/${widget.imei}.flv')
//       ..initialize().then((_) {
//         videoPlayerController0.play();
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });

//     startDateController.text =
//         DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
//   }

//   setLiveStream(String cam) async {
//     final result =
//         await APIService().liveStreamDashcam(widget.imei, 'RTMP,ON,INOUT');
//     if (result is MessageModel) {
//       videoPlayerController0 = VideoPlayerController.network(
//           'https://api-apps.gps.id/media/live/$cam/${widget.imei}.flv')
//         ..initialize().then((_) {
//           videoPlayerController0.play();
//           // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//           setState(() {});
//         });
//     }
//   }

//   void listener() async {
//     if (!mounted) return;
//     //
//     if (videoPlayerController0.value.isInitialized) {
//       var oPosition = videoPlayerController0.value.position;
//       var oDuration = videoPlayerController0.value.duration;
//       if (oPosition != null && oDuration != null) {
//         if (oDuration.inHours == 0) {
//           var strPosition = oPosition.toString().split('.')[0];
//           var strDuration = oDuration.toString().split('.')[0];
//           position =
//               "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
//           duration =
//               "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
//         } else {
//           position = oPosition.toString().split('.')[0];
//           duration = oDuration.toString().split('.')[0];
//         }
//         validPosition = oDuration.compareTo(oPosition) >= 0;
//         sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
//       }
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: bluePrimary,
//             title: Column(
//               children: [
//                 Text(
//                   'Dashcam',
//                   style: bold.copyWith(
//                     fontSize: 14,
//                     color: whiteColor,
//                   ),
//                 ),
//                 Text(
//                   widget.vehName,
//                   style: bold.copyWith(
//                     fontSize: 10,
//                     color: whiteColor,
//                   ),
//                 )
//               ],
//             ),
//             bottom: TabBar(
//               tabs: [
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 3),
//                         child: Image.asset(
//                           'assets/icon/dashcam/dashcam.png',
//                           width: 25,
//                           height: 25,
//                         ),
//                       ),
//                       Text('Live Stream')
//                     ],
//                   ),
//                 ),
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 3),
//                         child: Image.asset(
//                           'assets/icon/dashcam/history.png',
//                           width: 25,
//                           height: 25,
//                         ),
//                       ),
//                       Text('History')
//                     ],
//                   ),
//                 )
//               ],
//               indicatorColor: whiteColor,
//             ),
//           ),
//           body: TabBarView(
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               Stack(
//                 children: [
//                   Column(
//                     children: [
//                       SizedBox(
//                         child: AspectRatio(
//                           aspectRatio: 16 / 9,
//                           child: VideoPlayer(videoPlayerController0),
//                         ),
//                       ),
//                       const Expanded(
//                         child: GoogleMap(
//                           myLocationEnabled: true,
//                           zoomControlsEnabled: false,
//                           myLocationButtonEnabled: false,
//                           initialCameraPosition: CameraPosition(
//                               target: LatLng(-6.187233, 106.8060391), zoom: 17),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     bottom: 30,
//                     left: 20,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       width: 335,
//                       height: 141,
//                       decoration: BoxDecoration(
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.grey,
//                             offset: Offset(0.0, 3),
//                             blurRadius: 9.0,
//                           ),
//                         ],
//                         color: whiteColor,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'B 1234 ZEE',
//                             style: bold.copyWith(
//                                 color: blackPrimary, fontSize: 16),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 5),
//                                 child: Container(
//                                   height: 23,
//                                   width: 140,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(4),
//                                     color: whiteCardColor,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Expanded(
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             Icon(
//                                               Icons.circle,
//                                               size: 8,
//                                               color: redPrimary,
//                                             ),
//                                             Text(
//                                               'Limit Stream : ',
//                                               style: reguler.copyWith(
//                                                   color: blackPrimary,
//                                                   fontSize: 10),
//                                             ),
//                                             Text(
//                                               '00:11:30',
//                                               style: bold.copyWith(
//                                                   color: blackPrimary,
//                                                   fontSize: 10),
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 5),
//                                 child: Container(
//                                   height: 32,
//                                   width: 88,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(4),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topRight,
//                                       end: Alignment.bottomLeft,
//                                       colors: [
//                                         blueGradientSecondary1,
//                                         blueGradientSecondary2,
//                                       ],
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Icon(
//                                         Icons.camera_alt_rounded,
//                                         size: 14,
//                                         color: whiteColor,
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           if (cam == 1) {
//                                             videoPlayerController0.dispose();
//                                             setLiveStream('1');
//                                             // videoPlayerController0.dispose();
//                                             setState(() {
//                                               cam = 2;
//                                             });
//                                           } else {
//                                             // _getVLC = getVLC();
//                                             videoPlayerController0.dispose();
//                                             setLiveStream('0');
//                                             // videoPlayerController0.dispose();
//                                             setState(() {
//                                               cam = 1;
//                                             });
//                                           }
//                                         },
//                                         child: Text(
//                                           'CAM $cam',
//                                           style: bold.copyWith(
//                                               color: whiteColor, fontSize: 16),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 10),
//                             child: Divider(
//                               height: .5,
//                               thickness: .5,
//                               color: whiteCardColor,
//                               endIndent: 0,
//                               indent: 0,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 10),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     if (videoPlayerController0
//                                         .value.isPlaying) {
//                                       videoPlayerController0.pause();
//                                       setState(() {});
//                                     } else {
//                                       // videoPlayerController0.play();
//                                       videoPlayerController0.dispose();
//                                       setLiveStream(cam == 1 ? '0' : '1');
//                                       setState(() {});
//                                     }
//                                   },
//                                   child: Image.asset(
//                                     videoPlayerController0.value.isPlaying
//                                         ? 'assets/icon/dashcam/pause.png'
//                                         : 'assets/icon/dashcam/play.png',
//                                     width: 25,
//                                     height: 25,
//                                   ),
//                                 ),
//                                 Image.asset(
//                                   'assets/icon/dashcam/takepict.png',
//                                   width: 25,
//                                   height: 25,
//                                 ),
//                                 Image.asset(
//                                   'assets/icon/dashcam/sound.png',
//                                   width: 25,
//                                   height: 25,
//                                 ),
//                                 Image.asset(
//                                   'assets/icon/dashcam/fullscreen.png',
//                                   width: 25,
//                                   height: 25,
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               const DashcamHistory()
//               // Container()
//               ,
//             ],
//           ),
//         ));
//   }
// }
