// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gpsid/model/localnotif.model.dart';
import 'package:gpsid/service/general.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationplugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Notifikasi GPSid', // id
    'GPSid Notification', // title
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notifgpsid'));

@pragma('vm:entry-point')
Future<void> backgroundMessage(RemoteMessage message) async {
  print(message);
  await Firebase.initializeApp();
  Platform.isAndroid
      ? flutterLocalNotificationplugin.show(
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
            sound: const RawResourceAndroidNotificationSound('notifgpsid'),
            groupKey: message.messageId,
          )))
      : {};
  // FirebaseMessaging.instance
  //     .getInitialMessage()
  //     .then((RemoteMessage? message) async {
  //   print(message);
  //   if (message is RemoteMessage) {
  //     await GeneralService()
  //         .writeLocalNotifAlarm(LocalNotifAlarmModel(isNotif: true));
  //   }
  // });
  await GeneralService()
      .writeLocalNotifAlarm(LocalNotifAlarmModel(isNotif: true));

  // storeToLocal(message);
}

Future<void> storeToLocal(RemoteMessage message) async {
  // final read = await GeneralService().readLocalNotifAlarm();
  // print(read);
  // if (read is! LocalNotifAlarmModel) {
  //   await GeneralService()
  //       .writeLocalNotifAlarm(LocalNotifAlarmModel(isNotif: true));
  // }
  await GeneralService()
      .writeLocalNotifAlarm(LocalNotifAlarmModel(isNotif: true));
}

class FirebaseBackground {
  initAndroid() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(backgroundMessage);
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) async {
    //   print(message);
    //   if (message is RemoteMessage) {
    //     await GeneralService()
    //         .writeLocalNotifAlarm(LocalNotifAlarmModel(isNotif: true));
    //   }
    // });
  }

  initIOS() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(backgroundMessage);
  }

  Future<String> getToken() async {
    late String token;
    await Firebase.initializeApp();
    final res = await FirebaseMessaging.instance.getToken();
    token = res.toString();
    print(token);
    return token;
  }

  Future<void> deleteToken() async {
    // await Firebase.initializeApp();
    await FirebaseMessaging.instance.deleteToken();

    print('Delete FCM Token');
    // return token;
  }

  subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }
}
