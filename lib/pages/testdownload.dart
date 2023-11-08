// // ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_print, avoid_function_literals_in_foreach_calls

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:gpsid/common.dart';
// import 'package:gpsid/model/assetmarker.model.dart';
// import 'package:gpsid/service/api.dart';
// import 'package:gpsid/service/general.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';

// class TestDownload extends StatefulWidget {
//   final String title;

//   const TestDownload({super.key, required this.title});

//   @override
//   TestDownloadState createState() => TestDownloadState();
// }

// class TestDownloadState extends State<TestDownload> {
//   DownloadAssetsController downloadAssetsController =
//       DownloadAssetsController();
//   String message = "Press the download button to start the download";
//   bool downloaded = false;
//   var list = [];

//   @override
//   void initState() {
//     super.initState();
//     checkPermission();
//   }

//   checkPermission() async {
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }
//   }

//   File? _displayImage;
//   final _disp = [];

//   // delete() async {
//   //   final dir = await path_provider.getApplicationSupportDirectory();
//   //   final setpath = Directory('${dir.path}/13');
//   //   setpath.delete();
//   // }

//   Future<void> createFolder() async {
//     final appDir = await path_provider.getApplicationDocumentsDirectory();
//     String folderName = 'local';
//     final newPath = Directory('${appDir.path}/$folderName');
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }
//     if (await newPath.exists()) {
//       print('udah ada');
//     } else {
//       newPath.create();
//       _download();
//     }
//   }

//   Future<void> getImage() async {
//     String folder = 'localAsset';
//     String fileName = '7_lost.png';
//     final appDir = await path_provider.getApplicationDocumentsDirectory();
//     final newPath = Directory('${appDir.path}/$folder');
//     final imageFile = File(path.setExtension(newPath.path, '/$fileName'));
//     setState(() {
//       _disp.clear();
//       _disp.add(imageFile);
//       _displayImage = _disp[0];
//     });
//   }

//   int idx = 0;
//   var imgFile = [];
//   var setImage = [];
//   late List<ResultsMarker> getResponse;
//   late List<IconMarkerUrl> response = [];

//   Future<void> _download() async {
//     Dialogs().loadingDialog(context);

//     final result = await APIService().getAsset();

//     if (result is AssetMarkerModel) {
//       // AssetMarkerModel getLocalAsset = await GeneralService().readLocalAsset();
//       // print(getLocalAsset);
//       // String jsonLocal = json.encode(getLocalAsset);
//       // String jsonResult = json.encode(result);
//       // if (jsonLocal != jsonResult) {
//       //   print('notSame');

//       // }
//       result.data.results.forEach((el) async {
//         el.marker.resultsMarker.forEach((el1) async {
//           final appDirII =
//               await path_provider.getApplicationDocumentsDirectory();
//           String folderName = el1.iconMarkerId.toString();
//           final newPath = Directory('${appDirII.path}/localAsset');
//           if (el1.iconMarkerId != 12) {
//             if (await newPath.exists()) {
//               final List<dynamic> imgName = [];
//               print('udah ada');
//               getResponse = el.marker.resultsMarker;
//               getResponse.forEach((el2) {
//                 if (el2.iconMarkerId == 12) {
//                 } else {
//                   if (el2.iconMarkerId == el1.iconMarkerId) {
//                     response = el2.iconMarkerUrl;
//                     response.forEach((el3) async {
//                       final res = [
//                         await http.get(Uri.parse(el3.accOn)),
//                         await http.get(Uri.parse(el3.alarm)),
//                         await http.get(Uri.parse(el3.lost)),
//                         await http.get(Uri.parse(el3.parking))
//                       ];
//                       imgName.addAll([
//                         '${el2.iconMarkerId}_accOn.png',
//                         '${el2.iconMarkerId}_alarm.png',
//                         '${el2.iconMarkerId}_lost.png',
//                         '${el2.iconMarkerId}_parking.png'
//                       ]);
//                       final localPath = [
//                         path.join(newPath.path, imgName[0]),
//                         path.join(newPath.path, imgName[1]),
//                         path.join(newPath.path, imgName[2]),
//                         path.join(newPath.path, imgName[3])
//                       ];
//                       localPath.forEach((Q) {
//                         final imageFile = File(Q);
//                         imgFile.addAll([imageFile]);
//                       });
//                       res.forEach((M) {
//                         final img = File(imgFile[idx].path);
//                         img.writeAsBytes(M.bodyBytes);
//                         setState(() {
//                           idx++;
//                         });
//                       });
//                     });
//                   }
//                 }
//               });
//             } else {
//               newPath.create();
//               final List<dynamic> imgName = [];
//               print('belum ada');
//               getResponse = el.marker.resultsMarker;
//               getResponse.forEach((el2) {
//                 if (el2.iconMarkerId == 12) {
//                 } else {
//                   if (el2.iconMarkerId == el1.iconMarkerId) {
//                     response = el2.iconMarkerUrl;
//                     response.forEach((el3) async {
//                       final res = [
//                         await http.get(Uri.parse(el3.accOn)),
//                         await http.get(Uri.parse(el3.alarm)),
//                         await http.get(Uri.parse(el3.lost)),
//                         await http.get(Uri.parse(el3.parking))
//                       ];
//                       imgName.addAll([
//                         '${el2.iconMarkerId}_accOn.png',
//                         '${el2.iconMarkerId}_alarm.png',
//                         '${el2.iconMarkerId}_lost.png',
//                         '${el2.iconMarkerId}_parking.png'
//                       ]);
//                       final localPath = [
//                         path.join(newPath.path, imgName[0]),
//                         path.join(newPath.path, imgName[1]),
//                         path.join(newPath.path, imgName[2]),
//                         path.join(newPath.path, imgName[3])
//                       ];
//                       localPath.forEach((Q) {
//                         final imageFile = File(Q);
//                         imgFile.addAll([imageFile]);
//                       });
//                       res.forEach((M) {
//                         final img = File(imgFile[idx].path);
//                         img.writeAsBytes(M.bodyBytes);
//                         setState(() {
//                           idx++;
//                         });
//                       });
//                     });
//                   }
//                 }
//               });
//             }
//           }
//         });
//       });

//       Dialogs().hideLoaderDialog(context);
//     } else {
//       print(result);
//       Dialogs().hideLoaderDialog(context);
//     }
//     // Dialogs().hideLoaderDialog(context);
//     // return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kindacode.com'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(25),
//           child: Column(
//             children: [
//               ElevatedButton(
//                   onPressed: _download, child: const Text('Download Image')),
//               ElevatedButton(
//                   onPressed: createFolder, child: const Text('Create folder')),
//               // ElevatedButton(
//               //     onPressed: delete, child: const Text('Delete folder')),
//               ElevatedButton(
//                   onPressed: () {
//                     getImage();
//                   },
//                   child: const Text('getImage')),
//               const SizedBox(height: 25),
//               _displayImage != null ? Image.file(_disp[0]) : Container()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
