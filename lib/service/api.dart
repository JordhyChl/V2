// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/alarm.model.dart';
import 'package:gpsid/model/alarmnotif.model.dart';
import 'package:gpsid/model/alarmtype.model.dart';
import 'package:gpsid/model/assetmarker.model.dart';
import 'package:gpsid/model/bank.model.dart';
import 'package:gpsid/model/banktransfer.model.dart';
import 'package:gpsid/model/banner.model.dart';
import 'package:gpsid/model/bodygooglelogin.model.dart';
import 'package:gpsid/model/bodylogin.model.dart';
import 'package:gpsid/model/branchregister.model.dart';
import 'package:gpsid/model/changepassword.model.dart';
import 'package:gpsid/model/checkemail.model.dart';
import 'package:gpsid/model/checkgsm.model.dart';
import 'package:gpsid/model/checkimei.model.dart';
import 'package:gpsid/model/checklimit.model.dart';
import 'package:gpsid/model/checkupdate.mode.dart';
import 'package:gpsid/model/commandlivestream.model.dart';
import 'package:gpsid/model/cspayment.model.dart';
import 'package:gpsid/model/currentpoin.sspoin.model.dart';
import 'package:gpsid/model/dashcamhistory.model.dart';
import 'package:gpsid/model/deleteaccount.model.dart';
import 'package:gpsid/model/detailAddCart.model.dart';
import 'package:gpsid/model/device.model.dart';
import 'package:gpsid/model/devicebusy.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/getcart.model.dart';
import 'package:gpsid/model/getclara.model.dart';
import 'package:gpsid/model/getnotificationsetting.model.dart';
import 'package:gpsid/model/getpackage.model.dart';
import 'package:gpsid/model/getparent.model.dart';
import 'package:gpsid/model/gopay.model.dart';
import 'package:gpsid/model/hourmeterreport.model.dart';
import 'package:gpsid/model/howtopay.model.dart';
import 'package:gpsid/model/infonotif.model.dart';
import 'package:gpsid/model/link.model.dart';
import 'package:gpsid/model/logout.model.dart';
import 'package:gpsid/model/mbp.model.dart';
import 'package:gpsid/model/npwp.model.dart';
import 'package:gpsid/model/paymentnotif.model.dart';
import 'package:gpsid/model/pendingtransaction.model.dart';
import 'package:gpsid/model/poi.model.dart';
import 'package:gpsid/model/pointhistory.model.dart';
import 'package:gpsid/model/profile.model.dart';
import 'package:gpsid/model/promonotif.model.dart';
import 'package:gpsid/model/qris.model.dart';
import 'package:gpsid/model/recurringhistdetail.model.dart';
import 'package:gpsid/model/recurringhistorylist.model.dart';
import 'package:gpsid/model/recurringstatusdetail.model.dart';
import 'package:gpsid/model/recurringstatuslist.model.dart';
import 'package:gpsid/model/redeemPulsaGetGSM.model.dart';
import 'package:gpsid/model/registerwithapple.model.dart';
import 'package:gpsid/model/registerwithgoogle.model.dart';
import 'package:gpsid/model/rewardlist.model.dart';
import 'package:gpsid/model/rewardstatus.model.dart';
import 'package:gpsid/model/runningreport.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/login.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/parkingreportlist.model.dart';
import 'package:gpsid/model/product.model.dart';
import 'package:gpsid/model/productdetail.model.dart';
import 'package:gpsid/model/sharelocation.model.dart';
import 'package:gpsid/model/stopreportlist.model.dart';
import 'package:gpsid/model/storelimit.model.dart';
import 'package:gpsid/model/storepayment.model.dart';
import 'package:gpsid/model/streaminglog.model.dart';
import 'package:gpsid/model/streetview.model.dart';
import 'package:gpsid/model/topuphistdetailmodel.dart';
import 'package:gpsid/model/topuphistlist.model.dart';
import 'package:gpsid/model/trackreplay.model.dart';
import 'package:gpsid/model/vehicledetail.model.dart';
import 'package:gpsid/model/vehicleiconregister.model.dart';
import 'package:gpsid/model/vehiclelist.model.dart';
import 'package:gpsid/model/vehiclestatus.model.dart';
import 'package:gpsid/model/vehicletyperegister.model.dart';
import 'package:gpsid/service/general.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:retry/retry.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;

class APIService {
  // final _env = 'prod';
  final _env = 'dev';
  final _urlProd = 'api-apps.gps.id';
  final _urlDev = 'api-apps.gps.id';
  final retryOpt = const RetryOptions(maxAttempts: 3);
  final _timeOpt = 40;
  String token = '';

  void printWarning(String text) {
    // print('\x1B[33m$text\x1B[0m');
    print(text);
  }

  getToken(String token) async {
    LocalData data = await GeneralService().readLocalUserStorage();
    // token = _data.Token;
    // print(token);
    DateTime? expiryDate = Jwt.getExpiryDate(data.Token);
    DateTime? dateTimeNow = DateTime.now();
    // ignore: unnecessary_brace_in_string_interps
    printWarning(
        'expired JWT = ${expiryDate!.toLocal()} vs date time now = $dateTimeNow');
    printWarning('token local = ${data.Token}');
    if (dateTimeNow.compareTo(expiryDate) > 0) {
      final response = await retryOpt.retry(
        () => http.get(
          setUri('jwt/RefreshToken'),
          headers: {HttpHeaders.authorizationHeader: token},
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      LocalData writeData = LocalData(
          ID: data.ID,
          Username: data.Username,
          Password: data.Password,
          Fullname: data.Fullname,
          Phone: data.Phone,
          Email: data.Email,
          Addres: data.Addres,
          CompanyName: data.CompanyName,
          BranchId: data.BranchId,
          Privilage: data.Privilage,
          Token: 'Bearer ${response.headers['token']}',
          SeenId: data.SeenId,
          IsGenerated: data.IsGenerated,
          IsGoogle: data.IsGoogle,
          IsApple: data.IsApple,
          createdAt: data.createdAt);
      await GeneralService().writeLocalUserStorage(writeData);
      printWarning('token new = ${response.headers['token'].toString()}');
      return response.headers['token'].toString();
    } else {
      return data.Token;
    }
    // return _data.Token;
  }

  getParent(String token) async {
    final result = await getAPIParent(token);
    if (result is GetParentModel) {
      List<dynamic> _getParent = [];
      _getParent.add(result.data.iD);
      if (result.data.parent.isNotEmpty) {
        for (var el in result.data.parent) {
          _getParent.add(el.iD);
        }
      }
      return _getParent;
    } else {
      return false;
    }
  }

  getAPIParent(String token) async {
    try {
      final response = await retryOpt.retry(
        () => http.get(
          setUri('vehiclelist/users'),
          headers: {HttpHeaders.authorizationHeader: token},
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // if (responseJson['data']['Parent'] == null) {

        // }
        // printWarning(responseJson);
        return GetParentModel.fromJson(responseJson);
      }
    } catch (error) {
      return ErrorTrapModel(
          isError: true,
          statusError: error.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }

    // return _data.Token;
  }

  setUri(String path) {
    if (_env == 'prod') {
      return Uri.https(_urlProd, '/$path');
    } else {
      return Uri.https(_urlDev, '/$path');
    }
  }

  Future<dynamic> doLogin(BodyLogin bodyLogin) async {
    try {
      printWarning('API - Login');
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('https://api-apps.gps.id/auth/login'));
      request.body = json.encode({
        "username": bodyLogin.username, //ganti jadi email
        "password": bodyLogin.password, //ganti jadi google id
        "fcm_token": bodyLogin.fcmToken,
        "is_ios": Platform.isIOS
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return LoginModel(
            status: responseJson['status'],
            message: responseJson['message'],
            data: DataLogin(
                ID: responseJson['data']['ID'],
                Username: responseJson['data']['Username'],
                Fullname: responseJson['data']['Fullname'],
                Phone: responseJson['data']['Phone'],
                Email: responseJson['data']['Email'],
                Addres: responseJson['data']['Addres'],
                CompanyName: responseJson['data']['Company_name'],
                BranchId: responseJson['data']['Branch_id'],
                Privilage: responseJson['data']['Privilage'],
                Token: 'Bearer ${response.headers['token']}',
                SeenId: responseJson['data']['Seen_id'],
                isGenerated: responseJson['data']['IsGenerated'],
                IsGoogle: responseJson['data']['IsGoogle'],
                IsApple: responseJson['data']['IsApple'],
                createdAt: responseJson['data']['Created_at']));
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doLoginGoogle(BodyLoginGoogle bodyLoginGoogle) async {
    try {
      printWarning('API - Login Google');
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/auth/login-google'));
      request.body = json.encode({
        "email": bodyLoginGoogle.email, //ganti jadi email
        "google_id": bodyLoginGoogle.googleid, //ganti jadi google id
        "fcm_token": bodyLoginGoogle.fcmToken,
        "is_ios": Platform.isIOS
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return LoginModel(
            status: responseJson['status'],
            message: responseJson['message'],
            data: DataLogin(
                ID: responseJson['data']['ID'],
                Username: responseJson['data']['Username'],
                Fullname: responseJson['data']['Fullname'],
                Phone: responseJson['data']['Phone'],
                Email: responseJson['data']['Email'],
                Addres: responseJson['data']['Addres'],
                CompanyName: responseJson['data']['Company_name'],
                BranchId: responseJson['data']['Branch_id'],
                Privilage: responseJson['data']['Privilage'],
                Token: 'Bearer ${response.headers['token']}',
                SeenId: responseJson['data']['Seen_id'],
                isGenerated: responseJson['data']['IsGenerated'],
                IsGoogle: responseJson['data']['IsGoogle'],
                IsApple: responseJson['data']['IsApple'],
                createdAt: responseJson['data']['Created_at']));
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doLoginApple(String userIdentifier, String fcm) async {
    try {
      printWarning('API - Login Apple');
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/auth/login-apple'));
      request.body = json.encode({
        "apple_id": userIdentifier,
        "fcm_token": fcm,
        "is_ios": Platform.isIOS
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return LoginModel(
            status: responseJson['status'],
            message: responseJson['message'],
            data: DataLogin(
                ID: responseJson['data']['ID'],
                Username: responseJson['data']['Username'],
                Fullname: responseJson['data']['Fullname'],
                Phone: responseJson['data']['Phone'],
                Email: responseJson['data']['Email'],
                Addres: responseJson['data']['Addres'],
                CompanyName: responseJson['data']['Company_name'],
                BranchId: responseJson['data']['Branch_id'],
                Privilage: responseJson['data']['Privilage'],
                Token: 'Bearer ${response.headers['token']}',
                SeenId: responseJson['data']['Seen_id'],
                isGenerated: responseJson['data']['IsGenerated'],
                IsGoogle: responseJson['data']['IsGoogle'],
                IsApple: responseJson['data']['IsApple'],
                createdAt: responseJson['data']['Created_at']));
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getBanner() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Banner list');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('banner/list'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return (responseJson['data']['Result'] as List)
            .map((p) => Result.fromJson(p))
            .toList();
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getProduct() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Product list');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          Uri.parse('https://api-apps.gps.id/product/list?page=1&perPage=10'),
          // setUri('product/list?page=1&perPage=10'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return ProductModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getProductDetail(int id) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Product list');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          Uri.parse('https://api-apps.gps.id/product/details/$id'),
          // setUri('product/list?page=1&perPage=10'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return ProductDetailModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getMoving() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Moving Vehicle');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('vehiclestatus/online'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return VehicleStatusModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPark() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Park Vehicle');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('vehiclestatus/parking'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return VehicleStatusModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getStop() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Stop Vehicle');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('vehiclestatus/stop'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return VehicleStatusModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPOI() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get POI');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('poi'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return POIModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getNoData() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get No Data Vehicle');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('vehiclestatus/noData'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return VehicleStatusModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getVehicleList(int page, int perPage) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Vehicle list');
      final token = await getToken(localData.Token);
      final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/vehiclelist/'));
      request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return VehicleListModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> searchVehicle(String value) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Search vehicle');
      final token = await getToken(localData.Token);
      final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/vehiclelist/search?search=$value'));
      request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['data']['result'] == null) {
          return null;
        } else {
          return VehicleListModel.fromJson(responseJson);
        }
        // return VehicleSearchModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getVehicleDetail(String imei) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Vehicle Detail');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          // setUri('vehicledetails/?imei=$imei'),
          Uri.parse('https://api-apps.gps.id/vehicledetails/?imei=$imei'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return VehicleDetailModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  // Future<dynamic> doShareLocation(ShareLocationPostModel shareLoc) async {
  //   var localData = await GeneralService().readLocalUserStorage();
  //   try {
  //     printWarning('API - Share Vehicle');
  //     final token = await getToken(localData.Token);
  //     final response = await retryOpt.retry(
  //       () => http
  //           .post(
  //             setUri('seen/share_location/add'),
  //             headers: {
  //               "Authorization": "Bearer $token",
  //             },
  //             body: shareLoc.toJson(),
  //           )
  //           .timeout(
  //             Duration(seconds: _timeOpt),
  //           ),
  //       retryIf: (e) => e is SocketException || e is TimeoutException,
  //     );
  //     var getRes = response;
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       var responseJson = json.decode(response.body);
  //       return ShareLocationResultModel.fromJson(responseJson['data']);
  //     } else {
  //       return ErrorTrapModel(
  //           isError: true,
  //           requestSent: getRes.request.toString(),
  //           statusError: getRes.statusCode.toString(),
  //           bodyError: response.reasonPhrase.toString());
  //     }
  //   } catch (err) {
  //     return ErrorTrapModel(
  //         isError: true,
  //         statusError: err.toString(),
  //         bodyError: '',
  //         requestSent: '');
  //   } finally {
  //     HttpClient().close();
  //   }
  // }
// visible: userName == 'demo' ? false : true,
  Future<dynamic> getStreetView(
      double _latitude, double _longitude, int _angle) async {
    try {
      printWarning('GetStreetView');
      final response = await retryOpt.retry(
        () => http
            .get(
              Uri.parse(
                  'https://maps.googleapis.com/maps/api/streetview/metadata?location=$_latitude,$_longitude&key=AIzaSyDE-j2fhzsuEHK2Re49FL2PKK75wpauoRQ'),
            )
            .timeout(
              Duration(seconds: _timeOpt),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var _getRes = response;

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return StreetViewModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: _getRes.request.toString(),
            statusError: _getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getStopReport(int page, int perPage, String imei,
      String timeStart, String timeEnd, int minDur, int maxDur) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Stop report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/stopreport/?minDuration=$minDur&maxDuration=$maxDur'));
      request.body = json
          .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // String data = json.encode(responseJson['data']);
        if (responseJson['status'] == false) {
          return MessageModel.fromJson(responseJson);
        } else {
          return StopReportListModel.fromJson(responseJson);
        }
        // if (responseJson['status'] == false) {
        //   print('stopreport false');
        //   return ErrorTrapModel(
        //       isError: true,
        //       requestSent: getRes.request.toString(),
        //       statusError: getRes.statusCode.toString(),
        //       bodyError: response.reasonPhrase.toString());
        // } else {
        //   print('stopreport true');
        //   return json.encode(responseJson['data']);
        //   // return StopReportListModel.fromJson(responseJson);
        // }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getParkingReport(int page, int perPage, String imei,
      String timeStart, String timeEnd, int minDur, int maxDur) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Parking report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/parkingreport/?minDuration=$minDur&maxDuration=$maxDur'));
      request.body = json
          .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['status'] == false) {
          return MessageModel.fromJson(responseJson);
        } else {
          return ParkingReportListModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getHourMeterReport(int page, int perPage, String imei,
      String timeStart, String timeEnd) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Hourmeter report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request =
          http.Request('POST', Uri.parse('https://api-apps.gps.id/hourmeter/'));
      request.body = json
          .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['status'] == false) {
          return json.encode(responseJson['status']);
        } else {
          return HourmeterReportModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRunningReport(int page, int perPage, String imei,
      String timeStart, String timeEnd) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Running report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/runningreport/'));
      request.body = json
          .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['status'] == false) {
          return json.encode(responseJson['status']);
        } else {
          return RunningReportModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getTrackReplay(int page, int perPage, String imei,
      String timeStart, String timeEnd) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Track replay');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/trackreplay/'));
      request.body = json
          .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['status'] == false) {
          return json.encode(responseJson['status']);
        } else {
          return TrackReplayModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAlarmType() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Alarm type');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          setUri('alarmtype/'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return AlarmTypeModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAlarmReport(int page, int perPage, String imei,
      String timeStart, String timeEnd, List<dynamic> alarmType) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Alarm report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/alarmreport/'));
      request.body = json.encode({
        "imei": imei,
        "timeStart": timeStart,
        "timeEnd": timeEnd,
        "alrmTypeID": alarmType
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['status'] == false) {
          return json.encode(responseJson['status']);
        } else {
          return AlarmReportModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  getIconFullGmaps(String iconLabel) async {
    try {
      printWarning('SeenApigetFullIconGmaps');
      final response = await retryOpt.retry(
        () => http
            .get(
              Uri.parse(iconLabel),
            )
            .timeout(
              Duration(seconds: _timeOpt),
            ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return response.bodyBytes;
    } catch (err) {
      return null;
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doShareLocation(String imei, String hour) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Share location');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/vehicledetails/geturlshare/?imei=$imei&hour=$hour'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return ShareLocationModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
      // if (response.statusCode == 200) {
      //   var responseJson = json.decode(response.body);
      //   // String data = json.encode(responseJson['data']);
      //   if (responseJson['status'] == false) {
      //     return json.encode(responseJson['status']);
      //   } else {
      //     return ShareLocationModel.fromJson(responseJson);
      //   }
      // } else {
      //   return ErrorTrapModel(
      //       isError: true,
      //       requestSent: getRes.request.toString(),
      //       statusError: getRes.statusCode.toString(),
      //       bodyError: response.reasonPhrase.toString());
      // }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doChangePassword(String oldPass, String newPass) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Change password');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request =
          http.Request('POST', Uri.parse('https://api-apps.gps.id/set/'));
      request.body =
          json.encode({"old_password": oldPass, "new_password": newPass});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return ChangePasswordModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doLogout() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Logout');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/auth/logout'));
      // request.body =`
      //     json.encode({"old_password": oldPass, "new_password": newPass});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        final dir = await path_provider.getApplicationDocumentsDirectory();
        final pathPoi = Directory('${dir.path}/Poi');
        final pathLocalAsset = Directory('${dir.path}/localAsset');
        await pathPoi.exists() ? pathPoi.deleteSync(recursive: true) : {};
        await pathLocalAsset.exists()
            ? pathLocalAsset.deleteSync(recursive: true)
            : {};
        var responseJson = json.decode(response.body);
        return LogoutModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAlarmNotif() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Alarm notif');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/alarmnotif/'));
      request.body = json.encode({
        "username": localData.Username,
        "alrmTypeID": [
          "main_power_off",
          "poi_in",
          "sos",
          "out_geofence",
          "in_geofence",
          "poi_out",
          "overspeed",
          "door_closed",
          "door_open",
          "min_temperature",
          "max_temperature",
          "engine_on",
          "engine_off",
          "speedlimit"
        ]
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return AlarmNotif.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPaymentNotif() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Payment notif');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/paymentnotif/'));
      request.body =
          json.encode({"username": localData.Username, "domain": "portal"});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return PaymentNotifModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPromoNotif() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Promo notif');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api-apps.gps.id/promonotif/get-all'));

      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return PromoNotifModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getInfoNotif(String username) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Info notif');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST',
          Uri.parse('https://api-apps.gps.id/info-notif/get-info-user'));
      request.body = json.encode({"username": username});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return InfoNotifModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getProfile() async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Profile');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          // setUri('vehicledetails/?imei=$imei'),
          Uri.parse('https://api-apps.gps.id/accountinfo/'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return ProfileModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> sendEmailVerif(String email) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Profile');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          // setUri('vehicledetails/?imei=$imei'),
          Uri.parse(
              'https://api-apps.gps.id/account/sendEmailVerify?email=$email'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> sendPhoneNumber(String phoneNumber) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Profile');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          // setUri('vehicledetails/?imei=$imei'),
          Uri.parse(
              'https://api-apps.gps.id/account/sendOtp?newPhone=$phoneNumber'),
          headers: {
            // 'Authorization':
            //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2Njc4NzgxNzEsImlhdCI6MTY2Nzg3NDU3MX0.-oG7-X_jrX6URTc9IZIhgQjVtrQHyXnHhVEZltC36Zk',
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> sendOTP(String OTP) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Profile');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          // setUri('vehicledetails/?imei=$imei'),
          Uri.parse('https://api-apps.gps.id/account/verifyOtp?otp=$OTP'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
            // 'Authorization':
            //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2Njc4NzgxNzEsImlhdCI6MTY2Nzg3NDU3MX0.-oG7-X_jrX6URTc9IZIhgQjVtrQHyXnHhVEZltC36Zk',
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> editProfile(
      String fullName,
      String username,
      String address,
      String companyName,
      int callPreference,
      String googleId,
      String appleId,
      String msgError) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Edit profile');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('PUT',
          Uri.parse('https://api-apps.gps.id/accountinfo/updateprofile'));
      request.body = json.encode({
        "fullname": fullName,
        "username": username,
        "address": address,
        "privilege": localData.Privilage,
        "company_name": companyName,
        "preferensi": callPreference,
        "google_id": googleId,
        "apple_id": appleId
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else if (response.statusCode == 409) {
        var responseJson = json.decode(response.body);
        MessageModel msg = MessageModel.fromJson(responseJson);
        // return MessageModel.fromJson(responseJson);
        return MessageModel(status: msg.status, message: msgError);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  // Future<dynamic> getPackage() async {
  Future<dynamic> getPackage(String gsm) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get package list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse('https://api-apps.gps.id/topup/api/package/get-package'));
          Uri.parse(
              'https://api-apps.gps.id/topup/v2/api/package/get-package?gsm=$gsm'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return GetPackageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  // Future<dynamic> addCart(
  //     String vehPlate, String gsmNumber, int topupPack) async {
  //   LocalData localData = await GeneralService().readLocalUserStorage();
  //   try {
  //     printWarning('API - Add cart');
  //     final token = await getToken(localData.Token);
  //     var headers = {
  //       'Authorization': token != localData.Token
  //           ? token.toString()
  //           : localData.Token.toString(),
  //       'Content-Type': 'application/json'
  //     };
  //     var request = http.Request(
  //         'POST', Uri.parse('https://api-apps.gps.id/topup/api/cart/add-cart'));
  //     request.body = json.encode({
  //       "user": {
  //         "username": localData.Username,
  //         "domain": "portal",
  //         "fullname": localData.Fullname
  //       },
  //       "vehicle": {"plate": vehPlate, "sim": gsmNumber},
  //       "top_up_pack_id": topupPack,
  //       "is_mobile": 1
  //     });
  //     request.headers.addAll(headers);
  //     final streamResponse = await request.send();
  //     var response = await http.Response.fromStream(streamResponse);
  //     var getRes = response;
  //     if (response.statusCode == 200) {
  //       var responseJson = json.decode(response.body);
  //       return MessageModel.fromJson(responseJson);
  //     }
  //     if (response.statusCode == 401) {
  //       var responseJson = json.decode(response.body);
  //       return MessageModel.fromJson(responseJson);
  //     }
  //     if (response.statusCode == 401) {
  //       var responseJson = json.decode(response.body);
  //       return MessageModel.fromJson(responseJson);
  //     } else {
  //       return ErrorTrapModel(
  //           isError: true,
  //           requestSent: getRes.request.toString(),
  //           statusError: getRes.statusCode.toString(),
  //           bodyError: response.reasonPhrase.toString());
  //     }
  //   } catch (err) {
  //     return ErrorTrapModel(
  //         isError: true,
  //         statusError: err.toString(),
  //         bodyError: '',
  //         requestSent: '');
  //   } finally {
  //     HttpClient().close();
  //   }
  // }

  Future<dynamic> addCartV2(List<DetailsCart> addToCart) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Add cart');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST',
          Uri.parse('https://api-apps.gps.id/topup/v2/api/cart/add-cart'));
      request.body = json.encode({
        "user": {
          "username": localData.Username,
          "domain": "portal",
          "fullname": localData.Fullname
        },
        "details": addToCart,
        "is_mobile": 1
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getCart() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get cart');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topup/api/cart/get-cart?username=${localData.Username}&domain=portal'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return GetCartModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getCartV2() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get cart');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topup/v2/api/cart/get-cart?username=${localData.Username}&domain=portal'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return GetCartModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPendingList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get pending list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topup/v2/api/payment/list-pending'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return PendingModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> deleteCart(int idCart) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Add cart');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('DELETE',
          Uri.parse('https://api-apps.gps.id/topup/api/cart/delete-cart'));
      request.body = json.encode({"cart_id": idCart});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> deleteCartV2(List<dynamic> idCart) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Add cart');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('DELETE',
          Uri.parse('https://api-apps.gps.id/topup/v2/api/cart/delete-cart'));
      request.body =
          json.encode({"username": localData.Username, "id_carts": idCart});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> updateCart(int idCart, int packID) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Update cart');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('PUT',
          Uri.parse('https://api-apps.gps.id/topup/api/cart/update-cart'));
      request.body = json.encode(
          {"cart_id": idCart, "is_mobile": 1, "top_up_pack_id": packID});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getBankList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get bank list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request('GET',
          Uri.parse('https://api-apps.gps.id/topup/api/payment/list-bank'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return BankCodeModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> csPayment() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - CS payment');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request('GET',
          Uri.parse('https://api-apps.gps.id/topup/api/payment/payment'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return StorePaymentModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  // Future<dynamic> topUp(String paymentVia, int npwp) async {
  //   LocalData localData = await GeneralService().readLocalUserStorage();
  //   try {
  //     printWarning('API - Top up payment');
  //     final token = await getToken(localData.Token);
  //     // final parent = await getParent(token);
  //     var headers = {
  //       'Authorization': token != localData.Token
  //           ? token.toString()
  //           : localData.Token.toString(),
  //       // 'Authorization':
  //       //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
  //       'Content-Type': 'application/json'
  //     };
  //     final resultNPWP =
  //         await APIService().getNPWP(localData.Username, 'portal');
  //     var request = http.Request('POST',
  //         Uri.parse('https://api-apps.gps.id/topup/api/payment/payment'));
  //     // request.body = json.encode({"parent": parent});
  //     // request.body = json.encode({
  //     //   "bank_code": paymentVia,
  //     //   "username": localData.Username,
  //     //   "domain": "portal"
  //     // });
  //     if (npwp == 1) {
  //       if (resultNPWP is NPWPmodel) {
  //         request.body = json.encode({
  //           "bank_code": paymentVia,
  //           "username": localData.Username,
  //           "domain": "portal",
  //           "npwp": {
  //             "npwp_no": resultNPWP.data.npwpNo,
  //             "npwp_name": resultNPWP.data.npwpName,
  //             "npwp_addr": resultNPWP.data.npwpAddr,
  //             "npwp_wa": resultNPWP.data.npwpWa,
  //             "npwp_email": resultNPWP.data.npwpEmail
  //           }
  //         });
  //       }
  //     } else {
  //       request.body = json.encode({
  //         "bank_code": paymentVia,
  //         "username": localData.Username,
  //         "domain": "portal",
  //         "npwp": {
  //           "npwp_no": "",
  //           "npwp_name": "",
  //           "npwp_addr": "",
  //           "npwp_wa": "",
  //           "npwp_email": ""
  //         }
  //       });
  //     }

  //     request.headers.addAll(headers);
  //     final streamResponse = await request.send();
  //     var response = await http.Response.fromStream(streamResponse);
  //     var getRes = response;
  //     if (response.statusCode == 200) {
  //       var responseJson = json.decode(response.body);
  //       if (responseJson['message'] == 'GoPay transaction is created') {
  //         return GoPayModel.fromJson(responseJson);
  //       } else if (responseJson['message'] == 'QRIS transaction is created') {
  //         return QRisModel.fromJson(responseJson);
  //       } else if (responseJson['message'] ==
  //           'OK, Mandiri Bill transaction is successful') {
  //         return MandiriBillPaymentModel.fromJson(responseJson);
  //       } else if (responseJson['message'] ==
  //           'Success, cstore transaction is successful') {
  //         return CSPaymentModel.fromJson(responseJson);
  //       } else {
  //         return BankTransfer.fromJson(responseJson);
  //       }
  //     }
  //     if (response.statusCode == 401) {
  //       var responseJson = json.decode(response.body);
  //       return MessageModel.fromJson(responseJson);
  //     } else {
  //       return ErrorTrapModel(
  //           isError: true,
  //           requestSent: getRes.request.toString(),
  //           statusError: getRes.statusCode.toString(),
  //           bodyError: response.reasonPhrase.toString());
  //     }
  //   } catch (err) {
  //     return ErrorTrapModel(
  //         isError: true,
  //         statusError: err.toString(),
  //         bodyError: '',
  //         requestSent: '');
  //   } finally {
  //     HttpClient().close();
  //   }
  // }

  Future<dynamic> topUpV2(
      String paymentVia,
      int npwp,
      List<dynamic> idCart,
      String npwpNo,
      String npwpName,
      String npwpAddress,
      String npwpWa,
      String npwpEmail) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Top up payment');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      // final resultNPWP =
      //     await APIService().getNPWP(localData.Username, 'portal');
      var request = http.Request('POST',
          Uri.parse('https://api-apps.gps.id/topup/v2/api/payment/checkout'));
      if (npwp == 1) {
        request.body = json.encode({
          "bank_code": paymentVia,
          "username": localData.Username,
          "domain": "portal",
          "id_carts": idCart,
          "npwp": {
            "npwp_no": npwpNo,
            "npwp_name": npwpName,
            "npwp_addr": npwpAddress,
            "npwp_wa": npwpWa,
            "npwp_email": npwpEmail
          }
        });
      } else {
        request.body = json.encode({
          "bank_code": paymentVia,
          "username": localData.Username,
          "domain": "portal",
          "id_carts": idCart,
          "npwp": {
            "npwp_no": "",
            "npwp_name": "",
            "npwp_addr": "",
            "npwp_wa": "",
            "npwp_email": ""
          }
        });
      }

      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['message'] == 'GoPay transaction is created') {
          return GoPayModel.fromJson(responseJson);
        } else if (responseJson['message'] == 'QRIS transaction is created') {
          return QRisModel.fromJson(responseJson);
        } else if (responseJson['message'] ==
            'OK, Mandiri Bill transaction is successful') {
          return MandiriBillPaymentModel.fromJson(responseJson);
        } else if (responseJson['message'] ==
            'Success, cstore transaction is successful') {
          return CSPaymentModel.fromJson(responseJson);
        } else {
          return BankTransfer.fromJson(responseJson);
        }
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> detailPending(String orderId) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Top up payment');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      // final resultNPWP =
      //     await APIService().getNPWP(localData.Username, 'portal');
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topup/v2/api/payment/detail-pending?order-id=$orderId'));

      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        if (responseJson['message'] == 'GoPay transaction is created') {
          return GoPayModel.fromJson(responseJson);
        } else if (responseJson['message'] == 'QRIS transaction is created') {
          return QRisModel.fromJson(responseJson);
        } else if (responseJson['message'] ==
            'OK, Mandiri Bill transaction is successful') {
          return MandiriBillPaymentModel.fromJson(responseJson);
        } else if (responseJson['message'] ==
            'Success, cstore transaction is successful') {
          return CSPaymentModel.fromJson(responseJson);
        } else {
          return BankTransfer.fromJson(responseJson);
        }
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkTransaction(String orderID) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Check transaction');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/topup/api/payment/check-transaction'));
      // request.body = json.encode({"parent": parent});
      request.body = json.encode({"order_id": orderID});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getNPWP(String username, String domain) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - NPWP');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse(
          //     'https://api-apps.gps.id/topup/api/cart/get-npwp?username=$username&domain=$domain'));
          Uri.parse('https://api-apps.gps.id/topup/v2/api/npwp/list-npwp'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return NPWPListModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> editNPWP(String username, String npwpNo, String npwpName,
      String npwpAddress, String npwpWA, String npwpEmail) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Edit NPWP');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/topup/api/cart/add-npwp'));
      request.body = json.encode({
        "username": username,
        "npwp_no": npwpNo,
        "npwp_name": npwpName,
        "npwp_addr": npwpAddress,
        "npwp_wa": npwpWA,
        "npwp_email": npwpEmail
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> stopRecurring(
      String username, String orderID, String domain) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Stop Recurring');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/topup/api/payment/stop-recurring'));
      request.body = json.encode(
          {"order_id": orderID, "username": username, "domain": domain});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getInstallment(Map<String, dynamic> _cardInfo) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Installment');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/topup/api/payment/payment/charge-option'));
      request.body = json.encode({
        "card_number": _cardInfo["cardNumber"].toString(),
        "exp_month": _cardInfo["cardExpDateMM"],
        "exp_year": '22${_cardInfo["cardExpDateYY"]}',
        "cvv": _cardInfo["cardCVV"].toString(),
        "username": localData.Username,
        "domain": "portal",
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return responseJson;
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAddress(String lat, String lon) async {
    try {
      final response = await retryOpt.retry(
        () => http.get(
          // https://seen.gps.id/backend/api/address?latitude=5.521475&longitude=95.3304183
          Uri.parse(
              'https://seen.gps.id/backend/api/address?latitude=$lat&longitude=$lon'),
          // Uri.parse('https://www.google.com/maps/place/$lat,$lon'),
          headers: {"Accept": "application/json"},
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: response.request.toString(),
            statusError: response.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          requestSent: err.toString(),
          statusError: '',
          bodyError: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAddressII(String lat, String lon) async {
    try {
      final response = await retryOpt.retry(
        () => http.get(
          // https://seen.gps.id/backend/api/address?latitude=5.521475&longitude=95.3304183
          Uri.parse('https://www.google.com/maps?q=$lat,$lon'),
          // Uri.parse('https://www.google.com/maps/place/$lat,$lon'),
          headers: {"Accept": "application/json"},
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: response.request.toString(),
            statusError: response.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          requestSent: err.toString(),
          statusError: '',
          bodyError: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRecurringHistDetail(String recurringNO) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Recurring history detail');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse(
          //     'https://api-apps.gps.id/recurringhistdetail?recurringNo=1231637132560'));
          Uri.parse(
              'https://api-apps.gps.id/recurringhistdetail?recurringNo=$recurringNO'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RecurringHistDetailModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRecurringHistList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Recurring history list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse('https://api-apps.gps.id/recurringhistlist?username=fdy'));
          Uri.parse(
              'https://api-apps.gps.id/recurringhistlist?username=${localData.Username}'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RecHistList.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRecurringStatusDetail(String orderID) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Recurring status detail');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse(
          //     'https://api-apps.gps.id/recurringstatdetail?OrderId=1231652427374'));
          Uri.parse(
              'https://api-apps.gps.id/recurringstatdetail?OrderId=$orderID'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RecurringStatusDetailModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRecurringStatusList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Recurring status list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          // Uri.parse('https://api-apps.gps.id/recurringstatlist?username=fdy'));
          Uri.parse(
              'https://api-apps.gps.id/recurringstatlist?username=${localData.Username}'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RecStatusList.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getTopupHistDetail(String orderId) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Recurring status list');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topuphistdetail?orderID=$orderId'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return TopUpHistDetailModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getTopupHistoryList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Top up history');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/topuphistlist?username=${localData.Username}'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return TopupHistModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getDeviceInfo(String imei) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Device info');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api-apps.gps.id/device?imei=$imei'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return DeviceModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getCurrentPoin() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - SSPOIN current poin');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMwLCJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJ1c2VyX3ZlcnNpb24iOiIyIiwidXNlcl9uYW1lIjoidG9uaXByYXMiLCJleHAiOjE2Nzk5NzU1NDcsImlhdCI6MTY2OTk3MTk0N30.jbD_oRIe1vI7-J1ytnMSRRWu1b4eVnADhESQJMtR6Oo',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api-sspoin.gps.id/history/currentPoint'));
      // request.body = json.encode({"parent": parent});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return SSPOINCurrentPoinModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getAsset() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Download asset');
      final token = await getToken(localData.Token);
      // final parent = await getParent(token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api-apps.gps.id/asset/get-asset'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return AssetMarkerModel.fromJson(responseJson);
      }
      if (response.statusCode == 401) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getPointHistory(String from, String to) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Point history');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-sspoin.gps.id/history/pointHistory?from_trx_date=$from&to_trx_date=$to&username=${localData.Username}'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return PointHistoryModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getURL() async {
    String dateTimeNow = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    // DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTimeNow);
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get URL');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-apps.gps.id/link/link-operational?date_now=$dateTimeNow'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return LinkModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRewardList() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Reward list');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request('GET',
          Uri.parse('https://api-sspoin.gps.id/reward/rewardListCategory'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return RewardListModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> redeemPoin(int id, String note) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem poin');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-sspoin.gps.id/redeem/requestRedeem'));
      request.body = json.encode({"reward_id": id, "note": note});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doSendCommand(String imei, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem poin');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-apps.gps.id/send/command-engine'));
      request.body = json.encode({"imei": imei, "command": command});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getRedeemStatus(String startDate, String endDate) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Reward status');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api-sspoin.gps.id/redeem/requestRedeem?from_trx_date=$startDate&to_trx_date=$endDate'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        if (responseJson['message'] == 'No request redeem') {
          return MessageModel.fromJson(responseJson);
        } else {
          return RedeemStatusModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getUpdateCheck() async {
    try {
      printWarning('GetCheckUpdate');
      final response = await retryOpt.retry(
        () => http.get(
          Uri.https(
              'seen.gps.id', '/backend/api/private/check_version/datatable'),
          headers: {
            "Accept": "application/json",
            "Authorization":
                "Application base64:51gpNTBDyh+llPPNL2KyDfQSKfOSVaLfFZ+byqr7CDc=",
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      // return response.bodyBytes;
      var _getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return (responseJson['data'])
            .map((p) => CheckUpdateModel.fromJson(p))
            .toList();
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: _getRes.request.toString(),
            statusError: _getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> cancelTransaction(String orderId) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem poin');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api-apps.gps.id/topup/api/payment/cancel-transaction'));
      request.body =
          json.encode({"username": localData.Username, "order_id": orderId});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> liveStreamDashcam(String imei, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Live Stream Dashcam');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request(
          'POST', Uri.parse('http://hub.gps.id:9080/api/device/sendInstruct'));
      request.bodyFields = {
        'imei': imei,
        'serverFlagId': '11',
        'proNo': '128',
        'platform': 'web',
        'requestId': '3',
        'cmdType': 'normalIns',
        'token': '123',
        'offlineFlag': 'true',
        'cmdContent': command
      };
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        if (responseJson['data']['_code'] == '302') {
          return DeviceBusyModel.fromJson(responseJson);
        }
        if (responseJson['data']['_code'] == '600') {
          return DeviceBusyModel.fromJson(responseJson);
        } else {
          return CommandDashcam.fromJson(responseJson);
        }
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> doSendCommandDashcam(String imei, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem poin');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://seen.gps.id/backend/api/dashcam/connect'));
      request.bodyFields = {'imei': imei, 'command': command};
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkLimit(String imei, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Dashcam Limit');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request(
          'POST', Uri.parse('https://seen.gps.id/backend/api/dashcam/connect'));
      request.bodyFields = {'imei': imei, 'command': command};
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return CheckLimitModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> liveStreamDashcamCommand(String imei, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Command Live Stream Dashcam');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST',
          Uri.parse('https://api-apps.gps.id/iothub/api/device/sendInstruct'));
      request.bodyFields = {
        'imei': imei,
        'serverFlagId': '11',
        'proNo': '128',
        'platform': 'web',
        'requestId': '3',
        'cmdType': 'normalIns',
        'token': '123',
        'offlineFlag': 'true',
        'cmdContent': command
      };
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        if (responseJson['data']['_code'] == '302') {
          return DeviceBusyModel.fromJson(responseJson);
        }
        if (responseJson['data']['_code'] == '600') {
          return DeviceBusyModel.fromJson(responseJson);
        } else {
          return CommandDashcam.fromJson(responseJson);
        }
        // return CommandDashcam.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> dashcamHistory(String imei, String date) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Point history');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://seen.gps.id/backend/api/dashcam/connect_history?imei=$imei&date=$date'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        // return PointHistoryModel.fromJson(responseJson);
        return DashcamHistoryModel.fromJson(responseJson);
      } else {
        var responseJson = json.decode(response.body);
        // return ErrorTrapModel(
        //     isError: true,
        //     requestSent: getRes.request.toString(),
        //     statusError: getRes.statusCode.toString(),
        //     bodyError: response.reasonPhrase.toString());
        return MessageModel(
            status: responseJson['status'], message: responseJson['message']);
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> storeLimit(String startDate, String endDate, String duration,
      String imei, String action, String cam, String command) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Store Limit Dashcam');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://seen.gps.id/backend/api/dashcam/store_log_streaming'));
      request.bodyFields = {
        'start_date': startDate,
        'end_date': endDate,
        'second_live': duration,
        'imei': imei,
        'action': action,
        'camera': cam,
        'cmd_content': command
      };
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return StoreLimitModel.fromJson(responseJson);
      }
      if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getStreamingLogReport(int page, int perPage, String imei,
      String timeStart, String timeEnd) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Stop report');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://seen.gps.id/backend/api/dashcam/datatable_log_streaming?page=$page&per_page=$perPage&device=$imei&start=$timeStart&end=$timeEnd'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // String data = json.encode(responseJson['data']);
        if (responseJson['status'] == false) {
          return MessageModel.fromJson(responseJson);
        } else {
          return StreamingLogModel.fromJson(responseJson);
        }
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> redeemPulsaGetGSM() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem pulsa get gsm');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api-sspoin.gps.id/redeem/gsmUser'));
      // request.body = json
      //     .encode({"imei": imei, "timeStart": timeStart, "timeEnd": timeEnd});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return RedeemPulsaGetGSMModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> redeemPulsa(String rewardId, int note) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Redeem pulsa');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://api-sspoin.gps.id/redeem/requestRedeem'));
      request.body = json.encode({"reward_id": rewardId, "note": note});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getNotificationSetting() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get notification setting');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://portal.gps.id/backend/seen/user_notif/datatable?user_id=${localData.SeenId}'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return GetNotificationSettingModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> setNotification(
      int alertNo, int isActive, String code) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Set Notification');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        // 'Authorization':
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJleHAiOjE2NjcyOTQ4MDUsImlhdCI6MTY2NzI5MTIwNX0.cEE0Qu8NW1L35dHycYrkH0prHn-nxHpueebMNrmqg24',
        'Content-Type': 'application/json'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://portal.gps.id/backend/seen/user_notif/set_active/${localData.SeenId}'));
      // request.body = json.encode({"parent": parent});
      request.fields.addAll({
        'alert_no': alertNo.toString(),
        'is_active': isActive.toString(),
        'code': code
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> setAllNotification(List<dynamic> setAllNotif) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Set Notification');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://portal.gps.id/backend/seen/user_notif/set_active_bulk'));
      request.body = json.encode({"list_alert": setAllNotif});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> getClara() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - Get Clara');
      final token = await getToken(localData.Token);
      var headers = {
        'Authorization': token != localData.Token
            ? token.toString()
            : localData.Token.toString(),
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://portal.gps.id/backend/seen/dashboard/clara_unit_expired'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        return GetClaraModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> registerEmail(String email, String password) async {
    try {
      printWarning('API - Email register');
      var headers = {
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request('POST',
          Uri.parse('https://register.gps.id/register/email-registration'));
      request.body = json.encode({
        "email": email,
        "password": password,
        "confirm_password": password,
        "is_mobile": 1
      });
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkEmail(String email) async {
    try {
      printWarning('API - Check email');
      var headers = {
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://register.gps.id/register/get-status-email-verification-mobile?email=$email'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return CheckEmailModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkImei(String token, String imei) async {
    try {
      printWarning('API - Check IMEI');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'POST', Uri.parse('https://register.gps.id/imei/detail-imei'));
      request.body = json.encode({"imei": imei});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return CheckImeiModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkGSM(String token, String gsm) async {
    try {
      printWarning('API - Check GSM');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'POST', Uri.parse('https://register.gps.id/gsmNo/cek-gsm'));
      request.body = json.encode({"gsm_number": gsm});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return CheckGSMModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> vehicleTypeRegister(String token) async {
    try {
      printWarning('API - Vehicle type');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'GET', Uri.parse('https://register.gps.id/vehicle_type/list'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return VehicleTypeRegisterModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> vehicleIconRegister(String token, int typeID) async {
    try {
      printWarning('API - Vehicle type');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request('GET',
          Uri.parse('https://register.gps.id/icon/list?veh_type_id=$typeID'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return VehicleIconRegisterModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> branchRegister(String token) async {
    try {
      printWarning('API - Vehicle type');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request =
          http.Request('GET', Uri.parse('https://register.gps.id/branch/list'));
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return BranchRegisterModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> registerAccount(String token, String data) async {
    try {
      printWarning('API - Register account');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'POST', Uri.parse('https://register.gps.id/register/store-data'));
      request.body = data;
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> registerWithGoogle(String email, String googleID) async {
    try {
      printWarning('API - Register account with google');
      var headers = {
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request(
          'POST', Uri.parse('https://register.gps.id/sso/sso-registration'));
      request.body = json.encode({"email": email, "google_id": googleID});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RegisterWithGoogleModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> registerWithApple(String email, String userIdentifier) async {
    try {
      printWarning('API - Register account with apple');
      var headers = {
        'Content-Type': 'application/json',
        'API-Key':
            '!E7ov0tNucevd&~=+Ez:fw5X2#Q;Bv#Ngz\$9eZHe=[tBs^Zkc2~_PuPp~U>}CRZ'
      };
      var request = http.Request('POST',
          Uri.parse('https://register.gps.id/sso/sso-apple-registration'));
      request.body = json.encode({"email": email, "apple_id": userIdentifier});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return RegisterWithAppleModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> deleteAccount(int userId) async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    final token = await getToken(localData.Token);
    try {
      printWarning('API - Delete account');
      var headers = {
        'Authorization': '$token',
        // 'Content-Type': 'application/json',
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://portal.gps.id/backend/api/user/delete_account/$userId'));
      // request.body = json.encode({"email": email, "google_id": googleID});
      request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return DeleteAccountModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> checkAccount(String token) async {
    try {
      printWarning('API - Check account');
      // var headers = {
      //   'Authorization': '$token',
      //   // 'Content-Type': 'application/json',
      // };
      var request = http.MultipartRequest('POST',
          Uri.parse('https://portal.gps.id/backend/api/check_status_account'));
      // request.body = json.encode({"email": email, "google_id": googleID});
      request.fields.addAll({'token': token});
      // request.headers.addAll(headers);
      final streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else if (response.statusCode == 400) {
        var responseJson = json.decode(response.body);
        return MessageModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }

  Future<dynamic> howToPay(String code) async {
    var localData = await GeneralService().readLocalUserStorage();
    try {
      printWarning('API - How to pau');
      final token = await getToken(localData.Token);
      final response = await retryOpt.retry(
        () => http.get(
          Uri.parse('https://api-subs.gps.id//how-to-pay?code=$code'),
          headers: {
            HttpHeaders.authorizationHeader:
                token != localData.Token ? token : localData.Token
          },
        ).timeout(
          Duration(seconds: _timeOpt),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var getRes = response;
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        // return (responseJson['data']['Result'] as List)
        //     .map((p) => Result.fromJson(p))
        //     .toList();
        return HowToPayModel.fromJson(responseJson);
      } else {
        return ErrorTrapModel(
            isError: true,
            requestSent: getRes.request.toString(),
            statusError: getRes.statusCode.toString(),
            bodyError: response.reasonPhrase.toString());
      }
    } catch (err) {
      return ErrorTrapModel(
          isError: true,
          statusError: err.toString(),
          bodyError: '',
          requestSent: '');
    } finally {
      HttpClient().close();
    }
  }
}
