// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/streetview.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';

class StreetView extends StatefulWidget {
  final double Latitude;
  final double Longitude;
  final int Angle;

  const StreetView(
      {Key? key,
      required this.Latitude,
      required this.Longitude,
      required this.Angle})
      : super(key: key);

  @override
  _StreetViewPageState createState() => _StreetViewPageState();
}

class _StreetViewPageState extends State<StreetView> {
  late double _latitude;
  late double _longitude;
  late int _angle;
  late Future<dynamic> _getStreetView;
  // List<StreetViewModel> _streetView;
  late StreetViewModel _streetView;
  bool _isError = false;
  late String _loadingStatus;

  @override
  void initState() {
    super.initState();
    _latitude = widget.Latitude;
    _longitude = widget.Longitude;
    _angle = widget.Angle;
    // Future.delayed(Duration.zero, () {
    //   _getStreetView = getStreetView();
    // });
    _getStreetView = getStreetView();
    // _getStreetView = getStreetView();
    _loadingStatus = '';
  }

  Future<dynamic> getStreetView() async {
    setState(() {
      _loadingStatus = 'Load Street View';
    });
    final _result =
        await APIService().getStreetView(_latitude, _longitude, _angle);
    if (_result is ErrorTrapModel) {
      setState(() {
        _isError = true;
        print('ERROR = $_isError');
        _loadingStatus = 'Failed load street view';
      });
    } else {
      setState(() {
        _isError = false;
        print('ERROR = $_isError');
        _loadingStatus = 'Success load street view';
      });
    }
    return _result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          children: [
            Text(
              'Street View',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder(
                future: _getStreetView,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is ErrorTrapModel || _isError) {
                      return const Center(
                        child: Text('Failed'),
                      );
                    } else if (snapshot.data is StreetViewModel) {
                      _streetView = snapshot.data;
                      if (_streetView.status == 'OK') {
                        return Stack(
                          children: [
                            FlutterGoogleStreetView(
                              /**
                   * It not necessary but you can set init position
                   * choice one of initPos or initPanoId
                   * do not feed param to both of them, or you should get assert error
                   */
                              //initPos: SAN_FRAN,
                              initPos: LatLng(_latitude, _longitude),
                              //initPanoId: SANTORINI,

                              /**
                   *  It is worked while you set initPos or initPanoId.
                   *  initSource is a filter setting to filter panorama
                   */
                              initSource: StreetViewSource.outdoor,

                              /**
                   *  It is worked while you set initPos or initPanoId.
                   *  initBearing can set default bearing of camera.
                   */
                              initBearing: _angle.toDouble(),

                              /**
                   *  It is worked while you set initPos or initPanoId.
                   *  initTilt can set default tilt of camera.
                   */
                              //initTilt: 30,

                              /**
                   *  It is worked while you set initPos or initPanoId.
                   *  initZoom can set default zoom of camera.
                   */
                              //initZoom: 1.5,

                              /**
                   *  iOS Only
                   *  It is worked while you set initPos or initPanoId.
                   *  initFov can set default fov of camera.
                   */
                              //initFov: 120,

                              /**
                   *  Web not support
                   *  Set street view can panning gestures or not.
                   *  default setting is true
                   */
                              //panningGesturesEnabled: false,

                              /**
                   *  Set street view shows street name or not.
                   *  default setting is true
                   */
                              //streetNamesEnabled: true,

                              /**
                   *  Set street view can allow user move to other panorama or not.
                   *  default setting is true
                   */
                              userNavigationEnabled: false,

                              /**
                   *  Web not support
                   *  Set street view can zoom gestures or not.
                   *  default setting is true
                   */
                              zoomGesturesEnabled: false,

                              // Web only
                              //addressControl: false,
                              //addressControlOptions: ControlPosition.bottom_center,
                              //enableCloseButton: false,
                              //fullscreenControl: false,
                              //fullscreenControlOptions: ControlPosition.bottom_center,
                              //linksControl: false,
                              //scrollwheel: false,
                              //panControl: false,
                              //panControlOptions: ControlPosition.bottom_center,
                              //zoomControl: false,
                              //zoomControlOptions: ControlPosition.bottom_center,
                              //visible: false,
                              //onCloseClickListener: () {},
                              // Web only

                              /**
                   *  To control street view after street view was initialized.
                   *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                   *  And you can using [controller] to control street view.
                   */
                              onStreetViewCreated:
                                  (StreetViewController controller) async {
                                /*controller.animateTo(
                        duration: 750,
                        camera: StreetViewPanoramaCamera(
                            bearing: 90, tilt: 30, zoom: 3));*/
                              },
                            )
                          ],
                        );
                      } else {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // GeneralService().showErrorTrapServerError(_errCode),
                            Text(
                              'StreetView not available',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(child: GeneralService().getIconLoading()),
                          Text(
                            '$_loadingStatus ...',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
          )
        ],
      ),
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: Scaffold(

    //   ),
    // );
  }
}
