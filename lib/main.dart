//MAIN

// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_import

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gpsid/model/alarmid.model.dart';
import 'package:gpsid/pages/VLCPlayerTest.dart';
import 'package:gpsid/pages/addUnit.dart';
import 'package:gpsid/pages/cancelpayment.dart';
import 'package:gpsid/pages/choosevehicle.topup.dart';
import 'package:gpsid/pages/dascham.dart';
import 'package:gpsid/pages/dashcamhistory.dart';
import 'package:gpsid/pages/detailpayment.dart';
import 'package:gpsid/pages/editemail.dart';
import 'package:gpsid/pages/expiredvehiclelist.dart';
import 'package:gpsid/pages/failedpayment.dart';
import 'package:gpsid/pages/notifdetail.dart';
import 'package:gpsid/pages/pendingpayment.dart';
import 'package:gpsid/pages/phoneNumber.dart';
import 'package:gpsid/pages/addtocartpage.dart';
import 'package:gpsid/pages/alarmreport.dart';
import 'package:gpsid/pages/auth.dart';
import 'package:gpsid/pages/cart.dart';
import 'package:gpsid/pages/changepassword.dart';
import 'package:gpsid/pages/comingsoon.dart';
import 'package:gpsid/pages/editprofile.dart';
import 'package:gpsid/pages/homepage.dart';
import 'package:gpsid/pages/hourmeter.dart';
import 'package:gpsid/pages/insertOTP.dart';
import 'package:gpsid/pages/notification.dart';
import 'package:gpsid/pages/redeempoint.dart';
import 'package:gpsid/pages/redeemststus.dart';
import 'package:gpsid/pages/streaminglog.dart';
import 'package:gpsid/pages/taxinvoiceview.dart';
import 'package:gpsid/pages/timeoutpage.dart';
import 'package:gpsid/pages/trackreplaypage.dart';
import 'package:gpsid/pages/runningreport.dart';
import 'package:gpsid/pages/landingCart.dart';
import 'package:gpsid/pages/licensesagreement.dart';
import 'package:gpsid/pages/otherpage.dart';
import 'package:gpsid/pages/parkingreport.dart';
import 'package:gpsid/pages/paymentmethod.dart';
import 'package:gpsid/pages/productdetail.dart';
import 'package:gpsid/pages/recurringstatusdetail.dart';
import 'package:gpsid/pages/recurringstatuslist.dart';
import 'package:gpsid/pages/searchvehicle.dart';
import 'package:gpsid/pages/stopreport.dart';
import 'package:gpsid/pages/recurringhisdetail.dart';
import 'package:gpsid/pages/recurringhistory.dart';
import 'package:gpsid/pages/sspoint.dart';
import 'package:gpsid/pages/taxinvoice.dart';
import 'package:gpsid/pages/thankspage.dart';
import 'package:gpsid/pages/topuphisdetail.dart';
import 'package:gpsid/pages/topuphistory.dart';
import 'package:gpsid/pages/tracking.dart';
import 'package:gpsid/pages/transaction.dart';
import 'package:gpsid/pages/vehicledetail.dart';
import 'package:gpsid/pages/vehicleinfo.dart';
import 'package:gpsid/pages/vehiclelist.dart';
import 'package:gpsid/pages/loginpage.dart';
import 'package:gpsid/pages/productlist.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/verifemailnow.dart';
import 'package:gpsid/pages/verifiyphonenow.dart';
import 'package:gpsid/pages/waitingforpayment.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/pages/deleteAccount.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/notification.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

int route = 0;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseBackground firebase;
  late bool darkMode;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    readTheme();
    super.initState();
    firebase = FirebaseBackground();
    getPermission();
    setPref();
    requestPermission();
  }

  requestPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  readTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Try reading data from the 'repeat' key. If it doesn't exist, returns null.
    final bool? darkmode = prefs.getBool('darkmode');
    darkMode = darkmode!;
  }

  setPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save an boolean value to 'repeat' key.
    final bool? darkmode = prefs.getBool('darkmode');
    final bool? biometricLogin = prefs.getBool('biometricLogin');
    if (darkmode is! bool) {
      await prefs.setBool('darkmode', false);
      ColorTheme().readTheme();
    } else {
      ColorTheme().readTheme();
    }
    if (biometricLogin is! bool) {
      await prefs.setBool('biometricLogin', false);
    }
  }

  getPermission() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      sync();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      sync();
    } else {
      print('User declined or has not accepted permission');
      // handleAsync();
    }
  }

  sync() async {
    if (Platform.isAndroid) {
      await firebase.initAndroid();
    }
    if (Platform.isIOS) {
      await firebase.initIOS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      navigatorKey: navKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('id', ''), // Indonesia, no country code
      ],
      theme: ThemeData(appBarTheme: const AppBarTheme(centerTitle: true)),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/login': (context) => LoginPage(
              darkMode: darkMode,
            ),
        // '/dashcam': (context) => const DashcamSample(
        //       imei: '',
        //       vehName: '',
        //     ),
        '/dashcamHistory': (context) => DashcamHistory(
              imei: '',
              deviceName: '',
              limit: 0,
              date: '',
              totalCamera: 0,
              darkMode: darkMode,
            ),
        '/dashcam': (context) => Dashcam(
              imei: '',
              expDate: '',
              deviceName: '',
              gpsType: '',
              vehStatus: '',
              icon: 0,
              isDashcam: false,
              limit: 0,
              totalCamera: 0,
              darkMode: darkMode,
            ),
        '/vlcplayertest': (context) => VlcPlayerTest(
            controller: VlcPlayerController.network(''),
            url: '',
            limit: '',
            camera: '',
            imei: '',
            file: ''),
        '/homepage': (context) => HomePage(
              selected: 0,
              darkMode: darkMode,
              secondAccess: false,
            ),
        '/productlist': (context) => ProdukList(
              darkMode: darkMode,
            ),
        '/notification': (context) => NotificationPage(
              fromNotif: false,
              id: 0,
              darkMode: darkMode,
            ),
        // '/pushNotification': (context) => const PushNotificationPage(tab: 1),
        '/notificationdetail': (context) => NotifDetail(
              title: '',
              desc: '',
              pic: '',
              snk: [],
              subtitle: '',
              from: '',
              darkMode: darkMode,
            ),
        '/vehiclelist': (context) => VehicleList(
              status: 'a',
              darkMode: darkMode,
            ),
        '/expiredvehiclelist': (context) => ExpiredVehicleList(
              darkMode: darkMode,
            ),
        '/tracking': (context) => Tracking(
              darkMode: darkMode,
            ),
        '/vehicledetail': (context) => VehicleDetail(
              imei: '123',
              expDate: '',
              deviceName: '',
              gpsType: '',
              vehStatus: '',
              icon: 0,
              darkMode: darkMode,
            ),
        '/cart': (context) => const Cart(),
        '/taxinvoice': (context) => TaxInvoice(
              idCart: const [],
              totalPrice: 0,
              totalUnit: 0,
              cart: const [],
              darkMode: darkMode,
            ),
        '/taxinvoiceview': (context) => const TaxInvoiceView(
            npwpaddr: '',
            npwpemail: '',
            npwpname: '',
            npwpno: '',
            npwpstatus: '',
            npwpwa: ''),
        '/landingcart': (context) => LandingCart(
              darkMode: darkMode,
            ),
        '/paymentmethod': (context) => PaymentMethod(
              totalPrice: 0,
              totalUnit: 0,
              npwp: 0,
              idCart: const [],
              npwpNo: '',
              npwpName: '',
              npwpAddress: '',
              npwpWa: '',
              npwpEmail: '',
              cart: const [],
              darkMode: darkMode,
            ),
        '/detailpayment': (context) => DetailPayment(
              paymentName: '',
              expired: 0,
              orderID: '',
              paymentNumber: '',
              totalAmount: '',
              gopay: '',
              mbp: '',
              transactionDate: 0,
              totalUnit: 0,
              npwpNo: '',
              npwpName: '',
              vehicleDetail: const [],
              darkMode: darkMode,
            ),
        '/editprofile': (context) => EditProfile(
              darkMode: darkMode,
            ),
        '/changepass': (context) => ChangePassword(
              darkMode: darkMode,
            ),
        '/otherpage': (context) => OtherPage(
              darkMode: darkMode,
              progressCount: 0,
              completeProfile: false,
            ),
        '/recurringstatuslist': (context) => RecurringStatusList(
              darkMode: darkMode,
            ),
        '/insertOTP': (context) => const InsertOTP(),
        '/addtocart': (context) => const AddCart(),
        '/recurringstatusdetail': (context) => RecurringStatusDetail(
              orderID: '',
              status: '',
              darkMode: darkMode,
            ),
        '/comingsoon': (context) => const ComingSoonPage(responseJSON: {}),
        // '/thankyoupage': (context) => const ThanksPage(
        //       responseJSON: {},
        //     ),
        '/thankyoupage': (context) => const ThanksPage(
              orderId: '',
            ),
        '/topuphistory': (context) => TopupHistory(
              darkMode: darkMode,
            ),
        '/topuphistorydetail': (context) => TopupHistoryDetail(
              orderID: '',
              darkMode: darkMode,
            ),
        '/searchvehicle': (context) => SearchVehicle(
              darkMode: darkMode,
            ),
        '/stopreport': (context) => StopReportPage(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              icon: '',
              darkMode: darkMode,
            ),
        // '/trackreplay': (context) => TrackReplayReport(),
        '/trackreplay': (context) => TrackreplayPage(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              vehicleStatus: '',
              icon: 0,
              darkMode: darkMode,
            ),
        '/parkingreport': (context) => ParkingReportPage(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              icon: '',
              darkMode: darkMode,
            ),
        '/hourmeter': (context) => HourMeterPage(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              icon: 0,
              darkMode: darkMode,
            ),
        '/runningreport': (context) => RunningReportPage(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              icon: 0,
              darkMode: darkMode,
            ),
        '/alarmreport': (context) => AlarmReport(
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              licensePlate: '0',
              expDate: '0',
              alarmID: AlarmIDModel(alarmID: []),
              darkMode: darkMode,
            ),
        '/productdetail': (context) => ProductDetail(
              productID: 1,
              productName: '',
              darkMode: darkMode,
            ),
        '/licensesagreement': (context) => const LicenseAgreementPage(),
        '/recurringhistory': (context) => RecurringHistory(
              darkMode: darkMode,
            ),
        '/recurringdetail': (context) => RecurringHistoryDetail(
              recurringNo: '',
              darkMode: darkMode,
            ),
        '/vehicleinfo': (context) => VehicleInfo(
              status: '',
              odoMeter: '',
              warranty: '',
              activeWarranty: '',
              lastPosition: '',
              lastData: '',
              pulsaPackageEnd: '',
              vehiclePositionAddress: '',
              deviceName: '',
              gpsType: '',
              gsmNumber: '',
              imei: '',
              plate: '',
              latitude: 0.0,
              longitude: 0.0,
              registerDate: '',
              isDashcam: false,
              darkMode: darkMode,
            ),
        '/sspoin': (context) => SSPoint(
              darkMode: darkMode,
            ),
        '/redeempoint': (context) => RedeemPoint(
              darkMode: darkMode,
            ),
        '/editEmail': (context) => EditEmail(
              darkMode: darkMode,
            ),
        '/verifEmailNow': (context) => VerifEmailNow(
              darkMode: darkMode,
            ),
        '/phoneNumber': (context) => PhoneNumber(
              darkMode: darkMode,
            ),
        '/verifyPhoneNumber': (context) => VerifyPhoneNow(
              darkMode: darkMode,
            ),
        '/redeemStatus': (context) => RedeemStatus(
              darkMode: darkMode,
            ),
        // '/testdownload': (context) => const TestDownload(
        //       title: 'Coba download',
        //     ),
        // '/warp': (context) => WarpIndicator(
        //       onRefresh: () {
        //         return main();
        //       },
        //       child: LandingCart(),
        //     ),
        // '/customrefresh': (context) => PlaneIndicator(
        //         child: LandingCart(
        //       darkMode: darkMode,
        //     )),
        '/streaminglog': (context) => StreamingLog(
              vehName: '',
              imei: '0',
              timeStart: '0',
              timeEnd: '0',
              darkMode: darkMode,
            ),
        '/choosevehicletopup': (context) => ChooseVehicle(
              darkMode: darkMode,
              fromClara: false,
            ),
        '/transaction': (context) => Transaction(
              darkMode: darkMode,
            ),
        '/pendingpayment': (context) => PendingPayment(
              darkMode: darkMode,
            ),
        '/waitingforpayment': (context) => WaitingForPayment(
              darkMode: darkMode,
            ),
        '/timeoutpayment': (context) => const TimeoutPayment(),
        '/cancelpayment': (context) => CancelPayment(
              darkMode: darkMode,
            ),
        '/failedpayment': (context) => FailedPayment(
              darkMode: darkMode,
            ),
        '/addUnit': (context) => AddUnit(
              darkMode: darkMode,
              token: '',
              ownerName: '',
            ),
        '/deleteAccount': (context) => DeleteAccount(
              darkMode: darkMode,
              email: '',
              token: '',
            ),
      },
    );
  }
}
// const MyApp({Key? key}) : super(key: key);
