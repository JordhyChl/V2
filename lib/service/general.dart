// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gpsid/model/alarmid.model.dart';
import 'package:gpsid/model/alarmtype.model.dart';
import 'package:gpsid/model/assetmarker.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/localnotif.model.dart';
import 'package:gpsid/model/rememberme.model.dart';
import 'package:gpsid/model/storecart.model.dart';
import 'package:gpsid/widgets/notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recase/recase.dart';

class GeneralService {
  setTitleCase(String text) {
    ReCase rc = ReCase(text);

    return rc.titleCase;
  }

  late FirebaseBackground firebase;

  Future<String> getFCMToken() async {
    await Firebase.initializeApp();
    firebase = FirebaseBackground();
    return firebase.getToken();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localUserFile async {
    final path = await _localPath;
    return File('$path/udata.json');
  }

  Future<File> get rememberMeFile async {
    final path = await _localPath;
    return File('$path/rememberme.json');
  }

  Future<File> get localURL async {
    final path = await _localPath;
    return File('$path/url.json');
  }

  Future<File> get localAsset async {
    final path = await _localPath;
    return File('$path/localAsset.json');
  }

  Future<File> get _localAlarmType async {
    final path = await _localPath;
    return File('$path/alarmtypedata.json');
  }

  Future<File> get _localAlarmTypeID async {
    final path = await _localPath;
    return File('$path/alarmtypeIDdata.json');
  }

  Future<File> get _localCart async {
    final path = await _localPath;
    return File('$path/localCart.json');
  }

  Future<File> get localNotifAlarm async {
    final path = await _localPath;
    return File('$path/localNotifAlarm.json');
  }

  Future<File> get _localInboxFile async {
    final path = await _localPath;
    return File('$path/inboxdata.json');
  }

  Future<dynamic> readLocalInboxStorage() async {
    try {
      final file = await _localInboxFile;

      String _contents = await file.readAsString();

      return _contents;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<File> writeLocalInboxStorage(String _data) async {
    final file = await _localInboxFile;

    return file.writeAsString(_data);
  }

  Future<bool> deleteLocalInboxStorage() async {
    try {
      final file = await _localInboxFile;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File> get _localAlarmFile async {
    final path = await _localPath;
    return File('$path/alarmdata.json');
  }

  Future<dynamic> readAlarmStorage() async {
    try {
      final file = await _localAlarmFile;

      String _contents = await file.readAsString();

      return _contents;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<File> writeAlarmStorage(String _data) async {
    final file = await _localAlarmFile;

    return file.writeAsString(_data);
  }

  Future<bool> deleteAlarmStorage() async {
    try {
      final file = await _localAlarmFile;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> readLocalUserStorage() async {
    try {
      final file = await _localUserFile;

      String contents = await file.readAsString();
      var localData = json.decode(contents);
      LocalData data = LocalData.fromJson(localData);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readRememberMe() async {
    try {
      final file = await rememberMeFile;

      String contents = await file.readAsString();
      var rememberMe = json.decode(contents);
      RememberMe data = RememberMe.fromJson(rememberMe);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalUrl() async {
    try {
      final file = await localURL;

      String contents = await file.readAsString();
      var localUrl = json.decode(contents);
      LinkModel data = LinkModel.fromJson(localUrl);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalAsset() async {
    try {
      final file = await localAsset;

      String contents = await file.readAsString();
      var assetLocal = json.decode(contents);
      AssetMarkerModel data = AssetMarkerModel.fromJson(assetLocal);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalCart() async {
    try {
      final file = await _localCart;

      String contents = await file.readAsString();
      var localCart = json.decode(contents);
      StoreCart data = StoreCart.fromJson(localCart);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalNotifAlarm() async {
    try {
      final file = await localNotifAlarm;

      String contents = await file.readAsString();
      var _localNotifAlarm = json.decode(contents);
      LocalNotifAlarmModel data =
          LocalNotifAlarmModel.fromJson(_localNotifAlarm);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalAlarmStorage() async {
    try {
      final file = await _localAlarmType;

      String contents = await file.readAsString();
      var localData = json.decode(contents);
      // DataAlarmType data = DataAlarmType(result: [localData]);
      DataAlarmType data = DataAlarmType.fromJson(localData);
      // ResultAlarmType data = ResultAlarmType.fromJson(localData);
      // List<ResultAlarmType> data =
      //     ResultAlarmType.fromJson(localData) as List<ResultAlarmType>;

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<dynamic> readLocalAlarmTypeID() async {
    try {
      final file = await _localAlarmTypeID;

      String contents = await file.readAsString();
      var localData = json.decode(contents);
      AlarmIDModel data = AlarmIDModel.fromJson(localData);

      return data;
    } catch (e) {
      // If encountering an error, return 0
      return false;
    }
  }

  Future<File> writeLocalUserStorage(LocalData data) async {
    final file = await _localUserFile;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeRememberMe(RememberMe data) async {
    final file = await rememberMeFile;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalURL(LinkModel data) async {
    final file = await localURL;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalAsset(AssetMarkerModel data) async {
    final file = await localAsset;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalNotifAlarm(LocalNotifAlarmModel data) async {
    final file = await localNotifAlarm;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalCart(StoreCart data) async {
    final file = await _localCart;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalAlarmTypeStorage(DataAlarmType data) async {
    final file = await _localAlarmType;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<File> writeLocalAlarmTypeID(AlarmIDModel data) async {
    final file = await _localAlarmTypeID;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  Future<bool> deleteLocalUserStorage() async {
    try {
      final file = await _localUserFile;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRememberMe() async {
    try {
      final file = await rememberMeFile;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalURL() async {
    try {
      final file = await localURL;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalAsset() async {
    try {
      final file = await localAsset;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalNotifAlarm() async {
    try {
      final file = await localNotifAlarm;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalCart() async {
    try {
      final file = await _localCart;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalAlarmStorage() async {
    try {
      final file = await _localAlarmType;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalAlarmTypeID() async {
    try {
      final file = await _localAlarmTypeID;

      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
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
            GeneralService().setTitleCase(
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

  // getDate(DateTime newdate) {
  //   String cDate =
  //       '${newdate.year}-${newdate.month.toString().length > 1 ? newdate.month.toString() : '0${newdate.month}'}-${newdate.day.toString().length > 1 ? newdate.day.toString() : '0${newdate.day}'}';
  //   return cDate;
  // }

  getDate(DateTime newdate) {
    String cDate =
        '${newdate.year}-${newdate.month.toString().length > 1 ? newdate.month.toString() : '0${newdate.month}'}-${newdate.day.toString().length > 1 ? newdate.day.toString() : '0${newdate.day}'}';
    return cDate;
  }

  getTime(DateTime newdate) {
    String cTime =
        '${newdate.hour.toString().length > 1 ? newdate.hour.toString() : '0${newdate.hour}'}:${newdate.minute.toString().length > 1 ? newdate.minute.toString() : '0${newdate.minute}'}';
    return cTime;
  }
}
