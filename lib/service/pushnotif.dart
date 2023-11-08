// //PUSHNOTIF

// // ignore_for_file: unnecessary_type_check, no_leading_underscores_for_local_identifiers

// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:gpsid/common.dart';
// import 'package:gpsid/model/inbox.model.dart';
// import 'package:gpsid/model/localdata.model.dart';
// import 'package:gpsid/service/general.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationplugin =
//     FlutterLocalNotificationsPlugin();
// // final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

// const String _channelGroupIdAlarm = 'com.superspring.gpsid.ALARM';
// const String _channelGroupIdInbox = 'com.superspring.gpsid.INBOX';
// late LocalData _localdata;

// Future<void> _fbMsgBgHandler(RemoteMessage message) async {
//   NotificationDetails notificationDetailsPlatformSpefics = NotificationDetails(
//       android: AndroidNotificationDetails(
//     message.messageId!,
//     message.data['type'],
//     playSound: true,
//     sound: const RawResourceAndroidNotificationSound('notifgpsid'),
//     channelDescription: message.data['type'],
//     groupKey: message.messageId!,
//     importance: Importance.high,
//     priority: Priority.high,
//   ));

//   flutterLocalNotificationplugin.show(
//     message.hashCode,
//     message.notification!.title,
//     'BACKGROUND \u{1F514}' + ' ${message.data['en']}',
//     // '\u{1F600}', untuk icon U+1F600
//     // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//     notificationDetailsPlatformSpefics,
//   );

//   final _getLocalData = await GeneralService().readLocalUserStorage();
//   LocalData _localdata = _getLocalData;
//   if (_localdata.Username != message.data['username']) {
//     // if (message.data.containsKey('screen')) {
//     //   navigatorKey.currentState!.pushNamed('/productlist');
//     // }
//     await Firebase.initializeApp();
//     print("Handling a background message : ${message.messageId}");
//     print(message.data);
//     // await doLocalStorage(message);
//   } else {}
// }

// Future<void> doLocalStorage(RemoteMessage message) async {
//   // Database db = await DatabaseHelper.instance.database;
//   if (message.data['type'] == 'message') {
//     var now = DateTime.now();
//     InboxModel inbox = InboxModel(
//       id: 0,
//       type: message.data['type'] == 'alarm'
//           ? 1
//           : message.data['type'] == 'payment'
//               ? 2
//               : message.data['type'] == 'info'
//                   ? 3
//                   : message.data['type'] == 'promo'
//                       ? 4
//                       : 0,
//       message: jsonEncode(message.data),
//       createdAt:
//           GeneralService().getDate(now) + ' ' + GeneralService().getTime(now),
//       isRead: 0,
//       username: message.data['username'],
//     );
//     var read = await GeneralService().readLocalInboxStorage();

//     var result = [];
//     if (read is bool) {
//       // if (_localdata.platform == 'gpsid') {
//       //   inbox.id = 1;
//       //   result.add(inbox);
//       //   await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//       //   // print('HASIL1: ${jsonDecode(jsonEncode(_inbox))}');
//       //   // await db.insert(DatabaseHelper.tableInboxGPSid, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_inboxgpsid');
//       //   // print('DB GPSid #1 = $list');
//       // }
//       // if (_localdata.platform == 'seen') {
//       //   inbox.id = 1;
//       //   result.add(inbox);
//       //   await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//       //   // print('HASIL1: ${jsonDecode(jsonEncode(_inbox))}');
//       //   // await db.insert(DatabaseHelper.tableInbox, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_inbox');
//       //   // print('DB Seen #1 = $list');
//       // }
//       inbox.id = 1;
//       result.add(inbox);
//       await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//     } else {
//       // if (_localdata.platform == 'gpsid') {
//       //   result = jsonDecode(read);
//       //   inbox.id = result.length + 1;
//       //   result.add(jsonDecode(jsonEncode(inbox)));
//       //   await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//       //   // await db.insert(DatabaseHelper.tableInboxGPSid, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_inboxgpsid');
//       //   // print('DB GPSid #2 = $list');
//       // }
//       // if (_localdata.platform == 'seen') {
//       //   result = jsonDecode(read);
//       //   inbox.id = result.length + 1;
//       //   result.add(jsonDecode(jsonEncode(inbox)));
//       //   await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//       //   // await db.insert(DatabaseHelper.tableInbox, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_inbox');
//       //   // print('DB Seen #2= $list');
//       // }
//       result = jsonDecode(read);
//       inbox.id = result.length++;
//       result.add(jsonDecode(jsonEncode(inbox)));
//       await GeneralService().writeLocalInboxStorage(jsonEncode(result));
//     }
//   }
//   // if (message.data['type'] == 'notif') {
//   else {
//     var now = DateTime.now();
//     InboxModel inbox = InboxModel(
//       id: 0,
//       type: message.data['type'] == 'alarm'
//           ? 1
//           : message.data['type'] == 'payment'
//               ? 2
//               : message.data['type'] == 'info'
//                   ? 3
//                   : message.data['type'] == 'promo'
//                       ? 4
//                       : 0,
//       message: jsonEncode(message.data),
//       createdAt:
//           GeneralService().getDate(now) + ' ' + GeneralService().getTime(now),
//       isRead: 0,
//       username: message.data['username'],
//     );
//     var _read = await GeneralService().readLocalAlarmStorage();

//     var result = [];
//     if (_read is bool) {
//       // if (_localdata.platform == 'gpsid') {
//       //   _inbox.id = 1;
//       //   _result.add(_inbox);
//       //   await GeneralService().writeLocalAlarmStorage(jsonEncode(_result));
//       //   // print('HASIL1: ${jsonDecode(jsonEncode(_inbox))}');
//       //   // await db.insert(DatabaseHelper.tableAlarmGPSid, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_alarmgpsid');
//       //   // print('DB GPSid #1 = $list');
//       // }
//       // if (_localdata.platform == 'seen') {
//       //   _inbox.id = 1;
//       //   _result.add(_inbox);
//       //   await GeneralService().writeLocalAlarmStorage(jsonEncode(_result));
//       //   // print('HASIL1: ${jsonDecode(jsonEncode(_inbox))}');
//       //   // await db.insert(DatabaseHelper.tableAlarm, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_alarm');
//       //   // print('DB Seen #1 = $list');
//       // }
//       inbox.id = 1;
//       result.add(inbox);
//       await GeneralService().writeAlarmStorage(jsonEncode(result));
//     } else {
//       // if (_localdata.platform == 'gpsid') {
//       //   _result = jsonDecode(_read);
//       //   _inbox.id = _result.length + 1;
//       //   _result.add(jsonDecode(jsonEncode(_inbox)));
//       //   await GeneralService().writeLocalAlarmStorage(jsonEncode(_result));
//       //   // await db.insert(DatabaseHelper.tableAlarmGPSid, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_alarmgpsid');
//       //   // print('DB GPSid #2 = $list');
//       // }
//       // if (_localdata.platform == 'seen') {
//       //   _result = jsonDecode(_read);
//       //   _inbox.id = _result.length + 1;
//       //   _result.add(jsonDecode(jsonEncode(_inbox)));
//       //   await GeneralService().writeLocalAlarmStorage(jsonEncode(_result));
//       //   // await db.insert(DatabaseHelper.tableAlarm, _inbox.toJson());
//       //   // List<Map> list = await db.rawQuery('SELECT * FROM tb_alarm');
//       //   // print('DB Seen #2= $list');
//       // }
//       result = jsonDecode(_read);
//       inbox.id = result.length++;
//       result.add(jsonDecode(jsonEncode(inbox)));
//       await GeneralService().writeAlarmStorage(jsonEncode(result));
//     }
//   }
// }

// class FirebaseNotification {
//   initializeAndroid() async {
//     await Firebase.initializeApp();
//     FirebaseMessaging.onBackgroundMessage(_fbMsgBgHandler);

//     const AndroidNotificationChannelGroup _androidNotifChannelGroupAlarm =
//         AndroidNotificationChannelGroup(
//       _channelGroupIdAlarm,
//       'channel_group_alarm',
//       description: 'channel untuk grup notifikasi alarm',
//     );

//     const AndroidNotificationChannelGroup _androidNotifChannelGroupInbox =
//         AndroidNotificationChannelGroup(
//       _channelGroupIdInbox,
//       'channel_group_inbox',
//       description: 'channel untuk grup notifikasi inbox',
//     );

//     await flutterLocalNotificationplugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()!
//         .createNotificationChannelGroup(_androidNotifChannelGroupAlarm);

//     await flutterLocalNotificationplugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()!
//         .createNotificationChannelGroup(_androidNotifChannelGroupInbox);

//     const AndroidNotificationChannel('id', 'test');

//     const AndroidNotificationChannel _channelAlarm = AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title
//         sound: RawResourceAndroidNotificationSound('notifgpsid'),
//         description:
//             'This channel is used for alarm notifications.', // description
//         groupId: _channelGroupIdAlarm);

//     const AndroidNotificationChannel _channelInbox = AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title
//         sound: RawResourceAndroidNotificationSound('notifgpsid'),
//         description:
//             'This channel is used for inbox notifications.', // description
//         groupId: _channelGroupIdInbox);

//     await flutterLocalNotificationplugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channelAlarm);

//     await flutterLocalNotificationplugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channelInbox);

//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     var intializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings =
//         InitializationSettings(android: intializationSettingsAndroid);

//     flutterLocalNotificationplugin.initialize(initializationSettings);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       // String _lang = await GeneralService().readLocalLangStorage();

//       String? _title = message.notification!.title;
//       // String _body = '';
//       String? _body = notification!.body;
//       // Navigator.of(context).pushNamed('/topuphistory');
//       // String _body = notification.body;
//       final result = await GeneralService().readLocalUserStorage();
//       if (result is LocalData) {
//         // _localdata = result;
//         if (message.data['type'] == 'command') {
//           if (message.data['command'] == 'clearLocalUser') {
//             GeneralService().deleteLocalUserStorage();
//             String? _title = message.notification!.title;
//             String _body = '';

//             if (notification != null && android != null) {
//               if (message.data.isNotEmpty) {
//                 _body = message.data['en'];
//               } else {
//                 _body = notification.body!;
//               }

//               AndroidNotificationDetails notificationDetails =
//                   AndroidNotificationDetails(
//                 _channelAlarm.id,
//                 _channelAlarm.name,
//                 channelDescription: _channelAlarm.description,
//                 color: const Color(0xFF00a651),
//                 importance: Importance.max,
//                 priority: Priority.max,
//                 groupKey: _channelAlarm.groupId,
//               );

//               NotificationDetails notificationDetailsPlatformSpefics =
//                   NotificationDetails(android: notificationDetails);

//               flutterLocalNotificationplugin.show(
//                 notification.hashCode,
//                 _title,
//                 '\u{1F514}' + ' $_body',
//                 // '\u{1F600}', untuk icon U+1F600
//                 // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//                 notificationDetailsPlatformSpefics,
//               );
//             }

//             List<ActiveNotification>? activeNotifications =
//                 await flutterLocalNotificationplugin
//                     .resolvePlatformSpecificImplementation<
//                         AndroidFlutterLocalNotificationsPlugin>()
//                     ?.getActiveNotifications();

//             if (activeNotifications!.isNotEmpty) {
//               List<String> lines =
//                   activeNotifications.map((e) => e.title.toString()).toList();
//               InboxStyleInformation inboxStyleInformation =
//                   InboxStyleInformation(lines,
//                       contentTitle: "${activeNotifications.length - 1} alarms",
//                       summaryText: "${activeNotifications.length - 1} alarms");
//               AndroidNotificationDetails groupNotificationDetails =
//                   AndroidNotificationDetails(
//                       _channelAlarm.id, _channelAlarm.name,
//                       channelDescription: _channelAlarm.description,
//                       styleInformation: inboxStyleInformation,
//                       setAsGroupSummary: true,
//                       playSound: true,
//                       sound: const RawResourceAndroidNotificationSound(
//                           'notifgpsid'),
//                       groupKey: _channelAlarm.groupId);

//               NotificationDetails groupNotificationDetailsPlatformSpefics =
//                   NotificationDetails(android: groupNotificationDetails);
//               await flutterLocalNotificationplugin.show(
//                   0, '', '', groupNotificationDetailsPlatformSpefics);
//             }
//           }
//         } else {
//           if (result.Username != message.data['username']) {
//             // if (message.data.containsKey('screen')) {
//             //   navigatorKey.currentState!.pushNamed('/productlist');
//             // }
//             String? _title = message.notification!.title;
//             String? _body = '';

//             if (notification != null && android != null) {
//               if (message.data.isNotEmpty) {
//                 _body = message.data['en'];
//               } else {
//                 _body = notification.body;
//               }

//               // AndroidNotificationDetails notificationDetails =
//               //     AndroidNotificationDetails(
//               //   _channelAlarm.id,
//               //   _channelAlarm.name,
//               //   channelDescription: _channelAlarm.description,
//               //   color: const Color(0xFF00a651),
//               //   importance: Importance.max,
//               //   priority: Priority.max,
//               //   enableLights: true,
//               //   playSound: true,
//               //   sound: const RawResourceAndroidNotificationSound('notifgpsid'),
//               //   groupKey: _channelAlarm.groupId,
//               // );

//               AndroidNotificationSound soundTest =
//                   const RawResourceAndroidNotificationSound('notifgpsid');

//               NotificationDetails notificationDetailsPlatformSpefics =
//                   NotificationDetails(
//                       android: AndroidNotificationDetails(
//                 _channelAlarm.id,
//                 _channelAlarm.name,
//                 playSound: true,
//                 sound: soundTest,
//                 channelDescription: _channelAlarm.description,
//                 groupKey: _channelAlarm.groupId,
//                 importance: Importance.high,
//                 priority: Priority.high,
//               ));

//               flutterLocalNotificationplugin.show(
//                 notification.hashCode,
//                 _title,
//                 '\u{1F514}' + ' $_body',
//                 // '\u{1F600}', untuk icon U+1F600
//                 // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//                 notificationDetailsPlatformSpefics,
//               );

//               // flutterLocalNotificationplugin.initialize(initializationSettings,
//               //     onSelectNotification: selectNotificationAlarm);
//             }

//             List<ActiveNotification>? activeNotifications =
//                 await flutterLocalNotificationplugin
//                     .resolvePlatformSpecificImplementation<
//                         AndroidFlutterLocalNotificationsPlugin>()
//                     ?.getActiveNotifications();

//             if (activeNotifications!.isNotEmpty) {
//               List<String> lines =
//                   activeNotifications.map((e) => e.title.toString()).toList();
//               InboxStyleInformation inboxStyleInformation =
//                   InboxStyleInformation(lines,
//                       contentTitle: "${activeNotifications.length - 1} alarms",
//                       summaryText: "${activeNotifications.length - 1} alarms");
//               AndroidNotificationDetails groupNotificationDetails =
//                   AndroidNotificationDetails(
//                       _channelAlarm.id, _channelAlarm.name,
//                       channelDescription: _channelAlarm.description,
//                       styleInformation: inboxStyleInformation,
//                       setAsGroupSummary: true,
//                       importance: Importance.max,
//                       priority: Priority.max,
//                       enableLights: true,
//                       playSound: true,
//                       sound: const RawResourceAndroidNotificationSound(
//                           'notifgpsid'),
//                       groupKey: _channelAlarm.groupId);

//               NotificationDetails groupNotificationDetailsPlatformSpefics =
//                   NotificationDetails(android: groupNotificationDetails);
//               await flutterLocalNotificationplugin.show(
//                   0, '', '', groupNotificationDetailsPlatformSpefics);
//             }
//             // await doLocalStorage(message);
//           }
//         }
//       }

//       // if (message.data['type'] == 'notif') {
//       //   final _getLocalData = await GeneralService().readLocalUserStorage();
//       //   _localdata = _getLocalData;

//       //   if (_localdata.Username == message.data['username']) {
//       //     {
//       //       // String _title =
//       //       //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//       //       String? _title = message.notification!.title;
//       //       String _body = '';

//       //       if (notification != null && android != null) {
//       //         if (message.data.length > 0) {
//       //           _body = message.data['en'];
//       //         } else {
//       //           _body = notification.body!;
//       //         }

//       //         AndroidNotificationDetails notificationDetails =
//       //             AndroidNotificationDetails(
//       //           _channelAlarm.id,
//       //           _channelAlarm.name,
//       //           channelDescription: _channelAlarm.description,
//       //           color: Color(0xFF00a651),
//       //           importance: Importance.max,
//       //           priority: Priority.max,
//       //           groupKey: _channelAlarm.groupId,
//       //         );

//       //         NotificationDetails notificationDetailsPlatformSpefics =
//       //             NotificationDetails(android: notificationDetails);

//       //         flutterLocalNotificationplugin.show(
//       //           notification.hashCode,
//       //           _title,
//       //           '\u{1F514}' + ' $_body',
//       //           // '\u{1F600}', untuk icon U+1F600
//       //           // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//       //           notificationDetailsPlatformSpefics,
//       //         );

//       //         // flutterLocalNotificationplugin.initialize(initializationSettings,
//       //         //     onSelectNotification: selectNotificationAlarm);
//       //       }

//       //       List<ActiveNotification>? activeNotifications =
//       //           await flutterLocalNotificationplugin
//       //               .resolvePlatformSpecificImplementation<
//       //                   AndroidFlutterLocalNotificationsPlugin>()
//       //               ?.getActiveNotifications();

//       //       if (activeNotifications!.isNotEmpty) {
//       //         List<String> lines =
//       //             activeNotifications.map((e) => e.title.toString()).toList();
//       //         InboxStyleInformation inboxStyleInformation =
//       //             InboxStyleInformation(lines,
//       //                 contentTitle: "${activeNotifications.length - 1} alarms",
//       //                 summaryText: "${activeNotifications.length - 1} alarms");
//       //         AndroidNotificationDetails groupNotificationDetails =
//       //             AndroidNotificationDetails(
//       //                 _channelAlarm.id, _channelAlarm.name,
//       //                 channelDescription: _channelAlarm.description,
//       //                 styleInformation: inboxStyleInformation,
//       //                 setAsGroupSummary: true,
//       //                 groupKey: _channelAlarm.groupId);

//       //         NotificationDetails groupNotificationDetailsPlatformSpefics =
//       //             NotificationDetails(android: groupNotificationDetails);
//       //         await flutterLocalNotificationplugin.show(
//       //             0, '', '', groupNotificationDetailsPlatformSpefics);
//       //       }
//       //       // await doLocalStorage(message);
//       //     }
//       //   } else {}
//       // }

//       // if (message.data['type'] == 'message') {
//       //   final _getLocalData = await GeneralService().readLocalUserStorage();
//       //   _localdata = _getLocalData;

//       //   if (_localdata.username == message.data['username']) {
//       //     String _title = _lang == 'en'
//       //         ? message.data['midJson'] != null
//       //             ? 'GPS.id - Verified Payment'
//       //             : notification.title
//       //         : message.data['midJson'] != null
//       //             ? 'GPS.id - Pembayaran Terverifikasi'
//       //             : notification.title;
//       //     String _body = '';

//       //     if (notification != null && android != null) {
//       //       if (message.data.length > 0) {
//       //         _body = _lang == 'en'
//       //             ? '${message.data['en']}. Check inbox for more info'
//       //             : '${notification.body}. Cek inbox untuk informasi selengkapnya';
//       //       } else {
//       //         _body =
//       //             '${notification.body}. Cek inbox untuk informasi selengkapnya';
//       //       }

//       //       AndroidNotificationDetails notificationDetails =
//       //           AndroidNotificationDetails(
//       //         _channelInbox.id,
//       //         _channelInbox.name,
//       //         channelDescription: _channelInbox.description,
//       //         color: Color(0xFF00a651),
//       //         importance: Importance.max,
//       //         priority: Priority.max,
//       //         groupKey: _channelInbox.groupId,
//       //       );

//       //       NotificationDetails notificationDetailsPlatformSpefics =
//       //           NotificationDetails(android: notificationDetails);

//       //       flutterLocalNotificationplugin.show(
//       //         notification.hashCode,
//       //         _title,
//       //         '\u{1F4E9}' + ' $_body',
//       //         // '\u{1F600}', untuk icon U+1F600
//       //         // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//       //         notificationDetailsPlatformSpefics,
//       //       );

//       //       // flutterLocalNotificationplugin.initialize(initializationSettings,
//       //       //     onSelectNotification: selectNotificationMessage);
//       //     }

//       //     List<ActiveNotification> activeNotifications =
//       //         await flutterLocalNotificationplugin
//       //             .resolvePlatformSpecificImplementation<
//       //                 AndroidFlutterLocalNotificationsPlugin>()
//       //             ?.getActiveNotifications();

//       //     if (activeNotifications.length > 0) {
//       //       List<String> lines =
//       //           activeNotifications.map((e) => e.title.toString()).toList();
//       //       InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
//       //           lines,
//       //           contentTitle: "${activeNotifications.length - 1} inbox",
//       //           summaryText: "${activeNotifications.length - 1} inbox");
//       //       AndroidNotificationDetails groupNotificationDetails =
//       //           AndroidNotificationDetails(_channelInbox.id, _channelInbox.name,
//       //               channelDescription: _channelInbox.description,
//       //               styleInformation: inboxStyleInformation,
//       //               setAsGroupSummary: true,
//       //               groupKey: _channelInbox.groupId);

//       //       NotificationDetails groupNotificationDetailsPlatformSpefics =
//       //           NotificationDetails(android: groupNotificationDetails);
//       //       await flutterLocalNotificationplugin.show(
//       //           0, '', '', groupNotificationDetailsPlatformSpefics);
//       //     }

//       //     await doLocalStorage(message);
//       //   } else {}
//       // }
//     });
//   }

//   // initializeIOS() async {
//   //   await Firebase.initializeApp();
//   //   FirebaseMessaging.onBackgroundMessage(_fbMsgBgHandler);

//   //   await FirebaseMessaging.instance
//   //       .setForegroundNotificationPresentationOptions(
//   //     alert: true,
//   //     badge: true,
//   //     sound: true,
//   //   );

//   //   void onDidReceiveLocalNotification(
//   //       int id, String? title, String? body, String? payload) async {
//   //     print('test');
//   //   }

//   //   final DarwinInitializationSettings initializationSettingsIOS =
//   //       DarwinInitializationSettings(
//   //           onDidReceiveLocalNotification: onDidReceiveLocalNotification);

//   //   final InitializationSettings initializationSettings =
//   //       InitializationSettings(iOS: initializationSettingsIOS);

//   //   flutterLocalNotificationplugin.initialize(initializationSettings);

//   //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//   //     RemoteNotification? notification = message.notification;
//   //     AppleNotification? ios = message.notification?.apple;
//   //     // String _lang = await GeneralService().readLocalLangStorage();

//   //     if (message.data['type'] == 'command') {
//   //       if (message.data['command'] == 'clearLocalUser') {
//   //         GeneralService().deleteLocalUserStorage();
//   //         // String _title =
//   //         //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//   //         String? _title = message.notification!.title;
//   //         String _body = '';

//   //         if (notification != null && ios != null) {
//   //           if (message.data.length > 0) {
//   //             _body = message.data['en'];
//   //           } else {
//   //             _body = notification.body!;
//   //           }

//   //           DarwinNotificationDetails notificationDetails =
//   //               const DarwinNotificationDetails(
//   //             threadIdentifier: _channelGroupIdAlarm,
//   //           );

//   //           NotificationDetails notificationDetailsPlatformSpefics =
//   //               NotificationDetails(iOS: notificationDetails);

//   //           flutterLocalNotificationplugin.show(
//   //             notification.hashCode,
//   //             _title,
//   //             '\u{1F514}' + ' $_body',
//   //             // '\u{1F600}', untuk icon U+1F600
//   //             // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//   //             notificationDetailsPlatformSpefics,
//   //           );
//   //         }
//   //       }
//   //     } else {
//   //       if (_localdata.Username == message.data['username']) {
//   //         // String _title =
//   //         //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//   //         String? _title = message.notification!.title;
//   //         String _body = '';

//   //         if (notification != null && ios != null) {
//   //           if (message.data.length > 0) {
//   //             _body = message.data['en'];
//   //           } else {
//   //             _body = notification.body!;
//   //           }

//   //           DarwinNotificationDetails notificationDetails =
//   //               const DarwinNotificationDetails(
//   //             threadIdentifier: _channelGroupIdAlarm,
//   //           );

//   //           NotificationDetails notificationDetailsPlatformSpefics =
//   //               NotificationDetails(iOS: notificationDetails);

//   //           flutterLocalNotificationplugin.show(
//   //             notification.hashCode,
//   //             _title,
//   //             '\u{1F514}' + ' $_body',
//   //             // '\u{1F600}', untuk icon U+1F600
//   //             // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//   //             notificationDetailsPlatformSpefics,
//   //           );

//   //           // flutterLocalNotificationplugin.initialize(initializationSettings,
//   //           //     onSelectNotification: selectNotificationAlarm);
//   //           // await doLocalStorage(message);
//   //         }
//   //       } else {}
//   //     }

//   //     // if (message.data['type'] == 'notif') {
//   //     //   final _getLocalData = await GeneralService().readLocalUserStorage();
//   //     //   _localdata = _getLocalData;

//   //     //   if (_localdata.Username == message.data['username']) {
//   //     //     // String _title =
//   //     //     //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//   //     //     String? _title = message.notification!.title;
//   //     //     String _body = '';

//   //     //     if (notification != null && ios != null) {
//   //     //       if (message.data.length > 0) {
//   //     //         _body = message.data['en'];
//   //     //       } else {
//   //     //         _body = notification.body!;
//   //     //       }

//   //     //       DarwinNotificationDetails notificationDetails = const DarwinNotificationDetails(
//   //     //         threadIdentifier: _channelGroupIdAlarm,
//   //     //       );

//   //     //       NotificationDetails notificationDetailsPlatformSpefics =
//   //     //           NotificationDetails(iOS: notificationDetails);

//   //     //       flutterLocalNotificationplugin.show(
//   //     //         notification.hashCode,
//   //     //         _title,
//   //     //         '\u{1F514}' + ' $_body',
//   //     //         // '\u{1F600}', untuk icon U+1F600
//   //     //         // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//   //     //         notificationDetailsPlatformSpefics,
//   //     //       );

//   //     //       // flutterLocalNotificationplugin.initialize(initializationSettings,
//   //     //       //     onSelectNotification: selectNotificationAlarm);
//   //     //       // await doLocalStorage(message);
//   //     //     }
//   //     //   } else {}
//   //     // }

//   //     // if (message.data['type'] == 'message') {
//   //     //   final _getLocalData = await GeneralService().readLocalUserStorage();
//   //     //   _localdata = _getLocalData;

//   //     //   if (_localdata.username == message.data['username']) {
//   //     //     String _title = _lang == 'en'
//   //     //         ? message.data['midJson'] != null
//   //     //             ? 'GPS.id - Verified Payment'
//   //     //             : notification.title
//   //     //         : message.data['midJson'] != null
//   //     //             ? 'GPS.id - Pembayaran Terverifikasi'
//   //     //             : notification.title;
//   //     //     String _body = '';

//   //     //     if (notification != null && ios != null) {
//   //     //       if (message.data.length > 0) {
//   //     //         _body = _lang == 'en'
//   //     //             ? '${message.data['en']}. Check inbox for more info'
//   //     //             : '${notification.body}. Cek inbox untuk informasi selengkapnya';
//   //     //       } else {
//   //     //         _body =
//   //     //             '${notification.body}. Cek inbox untuk informasi selengkapnya';
//   //     //       }

//   //     //       IOSNotificationDetails notificationDetails = IOSNotificationDetails(
//   //     //         threadIdentifier: _channelGroupIdInbox,
//   //     //       );

//   //     //       NotificationDetails notificationDetailsPlatformSpefics =
//   //     //           NotificationDetails(iOS: notificationDetails);

//   //     //       flutterLocalNotificationplugin.show(
//   //     //         notification.hashCode,
//   //     //         _title,
//   //     //         '\u{1F4E9}' + ' $_body',
//   //     //         // '\u{1F600}', untuk icon U+1F600
//   //     //         // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//   //     //         notificationDetailsPlatformSpefics,
//   //     //       );

//   //     //       // flutterLocalNotificationplugin.initialize(initializationSettings,
//   //     //       //     onSelectNotification: selectNotificationMessage);

//   //     //       await doLocalStorage(message);
//   //     //     }
//   //     //   } else {}
//   //     // }
//   //   });
//   // }

//   initializeIOS() async {
//     await Firebase.initializeApp();
//     FirebaseMessaging.onBackgroundMessage(_fbMsgBgHandler);

//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     void onDidReceiveLocalNotification(
//         int? id, String? title, String? body, String? payload) async {
//       print('test');
//     }

//     final DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//             onDidReceiveLocalNotification: onDidReceiveLocalNotification);

//     final InitializationSettings initializationSettings =
//         InitializationSettings(iOS: initializationSettingsIOS);

//     flutterLocalNotificationplugin.initialize(initializationSettings);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       RemoteNotification? notification = message.notification;
//       AppleNotification? ios = message.notification?.apple;
//       final result = await GeneralService().readLocalUserStorage();
//       // String _lang = await GeneralService().readLocalLangStorage();
//       if (result is LocalData) {
//         if (message.data['type'] == 'command') {
//           if (message.data['command'] == 'clearLocalUser') {
//             GeneralService().deleteLocalUserStorage();
//             // String _title =
//             //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//             String? _title = message.notification?.title;
//             String? _body = '';

//             if (notification != null && ios != null) {
//               if (message.data.length > 0) {
//                 // _body = _lang == 'en' ? message.data['en'] : notification.body;
//                 _body = message.data['en'];
//               } else {
//                 _body = notification.body;
//               }

//               DarwinNotificationDetails notificationDetails =
//                   const DarwinNotificationDetails(
//                 threadIdentifier: _channelGroupIdAlarm,
//               );

//               NotificationDetails notificationDetailsPlatformSpefics =
//                   NotificationDetails(iOS: notificationDetails);

//               flutterLocalNotificationplugin.show(
//                 notification.hashCode,
//                 _title,
//                 '\u{1F514}' + ' $_body',
//                 // '\u{1F600}', untuk icon U+1F600
//                 // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//                 notificationDetailsPlatformSpefics,
//               );
//             }
//           }
//         } else {
//           if (result.Username != message.data['username']) {
//             // String _title =
//             //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//             String? _title = message.notification?.title;
//             String? _body = '';

//             if (notification != null && ios != null) {
//               if (message.data.isNotEmpty) {
//                 // _body = _lang == 'en' ? message.data['en'] : notification.body;
//                 _body = message.data['en'];
//               } else {
//                 _body = notification.body;
//               }

//               DarwinNotificationDetails notificationDetails =
//                   const DarwinNotificationDetails(
//                 threadIdentifier: _channelGroupIdAlarm,
//               );

//               NotificationDetails notificationDetailsPlatformSpefics =
//                   NotificationDetails(iOS: notificationDetails);

//               flutterLocalNotificationplugin.show(
//                 notification.hashCode,
//                 _title,
//                 '\u{1F514}' + ' $_body',
//                 // '\u{1F600}', untuk icon U+1F600
//                 // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//                 notificationDetailsPlatformSpefics,
//               );

//               // flutterLocalNotificationplugin.initialize(initializationSettings,
//               //     onSelectNotification: selectNotificationAlarm);
//               // await doLocalStorage(message);
//             }
//           }
//         }
//       }

//       // if (message.data['type'] == 'notif') {
//       //   final _getLocalData = await GeneralService().readLocalUserStorage();
//       //   _localdata = _getLocalData;

//       //   if (_localdata.Username == message.data['username']) {
//       //     // String _title =
//       //     //     _lang == 'en' ? 'GPS.id - Alarm' : 'Peringatan - GPS.id';
//       //     String? _title = message.notification?.title;
//       //     String? _body = '';

//       //     if (notification != null && ios != null) {
//       //       if (message.data.length > 0) {
//       //         // _body = _lang == 'en' ? message.data['en'] : notification.body;
//       //         _body = message.data['en'];
//       //       } else {
//       //         _body = notification.body;
//       //       }

//       //       IOSNotificationDetails notificationDetails = IOSNotificationDetails(
//       //         threadIdentifier: _channelGroupIdAlarm,
//       //       );

//       //       NotificationDetails notificationDetailsPlatformSpefics =
//       //           NotificationDetails(iOS: notificationDetails);

//       //       flutterLocalNotificationplugin.show(
//       //         notification.hashCode,
//       //         _title,
//       //         '\u{1F514}' + ' $_body',
//       //         // '\u{1F600}', untuk icon U+1F600
//       //         // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//       //         notificationDetailsPlatformSpefics,
//       //       );

//       //       // flutterLocalNotificationplugin.initialize(initializationSettings,
//       //       //     onSelectNotification: selectNotificationAlarm);
//       //       // await doLocalStorage(message);
//       //     }
//       //   } else {}
//       // }

//       // if (message.data['type'] == 'message') {
//       //   final _getLocalData = await GeneralService().readLocalUserStorage();
//       //   _localdata = _getLocalData;

//       //   if (_localdata.username == message.data['username']) {
//       //     String _title = _lang == 'en'
//       //         ? message.data['midJson'] != null
//       //             ? 'GPS.id - Verified Payment'
//       //             : notification.title
//       //         : message.data['midJson'] != null
//       //             ? 'GPS.id - Pembayaran Terverifikasi'
//       //             : notification.title;
//       //     String _body = '';

//       //     if (notification != null && ios != null) {
//       //       if (message.data.length > 0) {
//       //         _body = _lang == 'en'
//       //             ? '${message.data['en']}. Check inbox for more info'
//       //             : '${notification.body}. Cek inbox untuk informasi selengkapnya';
//       //       } else {
//       //         _body =
//       //             '${notification.body}. Cek inbox untuk informasi selengkapnya';
//       //       }

//       //       IOSNotificationDetails notificationDetails = IOSNotificationDetails(
//       //         threadIdentifier: _channelGroupIdInbox,
//       //       );

//       //       NotificationDetails notificationDetailsPlatformSpefics =
//       //           NotificationDetails(iOS: notificationDetails);

//       //       flutterLocalNotificationplugin.show(
//       //         notification.hashCode,
//       //         _title,
//       //         '\u{1F4E9}' + ' $_body',
//       //         // '\u{1F600}', untuk icon U+1F600
//       //         // '\x1B' + '[31m' + 'Hello' + '\x1B' + '[0m',
//       //         notificationDetailsPlatformSpefics,
//       //       );

//       //       // flutterLocalNotificationplugin.initialize(initializationSettings,
//       //       //     onSelectNotification: selectNotificationMessage);

//       //       // await doLocalStorage(message);
//       //     }
//       //   } else {}
//       // }
//     });
//   }

//   Future<String> getToken() async {
//     late String token;
//     await Firebase.initializeApp();
//     final res = await FirebaseMessaging.instance.getToken();
//     token = res.toString();
//     print(token);
//     return token;
//   }

//   Future<void> deleteToken() async {
//     // await Firebase.initializeApp();
//     await FirebaseMessaging.instance.deleteToken();

//     print('Delete FCM Token');
//     // return token;
//   }

//   subscribeToTopic(String topic) async {
//     await FirebaseMessaging.instance.subscribeToTopic(topic);
//   }
// }
