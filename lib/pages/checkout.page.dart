import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/pages/thankspage.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckOutPage extends StatefulWidget {
  final Map<String, dynamic> paramJSON;
  final bool darkMode;
  const CheckOutPage(
      {super.key, required this.paramJSON, required this.darkMode});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final Completer<WebViewController> _webViewCtrl =
      Completer<WebViewController>();
  late Future<dynamic> _createUrl;
  late String _loadHTML;
  final String _pulsaURL = 'https://pulsa2.gps.id/api/doCheckOut';

  @override
  void initState() {
    super.initState();
    _createUrl = createUrl();
  }

  Future<dynamic> createUrl() async {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    LocalData localData = await GeneralService().readLocalUserStorage();
    var paramJSON = widget.paramJSON;
    _loadHTML = '''<html>
              <body onload='document.f.submit();'>
                  <form id='f' name='f' method='post' action='$_pulsaURL'>
                    <input type='hidden' id='card_number' name='card_number' value='${paramJSON['cardNumber']}' />
                    <input type='hidden' id='exp_month' name='exp_month' value='${paramJSON['cardExpDateMM']}' />
                    <input type='hidden' id='exp_year' name='exp_year' value='${paramJSON['cardExpDateYY']}' />
                    <input type='hidden' id='cvv' name='cvv' value='${paramJSON['cardCVV']}' />
                    <input type='hidden' id='localData' name='localData' value='${jsonEncode(localData)}' />
                    <input type='hidden' id='installment' name='installment' value='${paramJSON['installment']}' />
                    <input type='hidden' id='is_recurring' name='is_recurring' value='${paramJSON['isRecurring']}' />
                    <input type='hidden' id='trxAmt' name='trxAmt' value='${paramJSON['trxAmt']}' />
                  </form>
              </body>
            </html>''';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                widget.darkMode ? whiteCardColor : blueGradientSecondary1,
                widget.darkMode ? whiteCardColor : blueGradientSecondary2,
              ],
            ),
          ),
        ),
        leading: IconButton(
          iconSize: 32,
          // padding: const EdgeInsets.only(top: 20),
          icon: const Icon(Icons.arrow_back_outlined),
          color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.checkOut,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteCardColor : whiteColor,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _createUrl,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child:

                      // InAppWebView(
                      //   initialUrlRequest: URLRequest(
                      //       url: Uri.parse(
                      //           'http://192.168.97.109:7082/v2/api/payment/installment'),
                      //       method: 'POST',
                      //       body: Uint8List.fromList(utf8.encode(json.encode({
                      //         "username": "tonipras",
                      //         "domain": "portal",
                      //         "token_id": "64d3626259e200001b70b4a0",
                      //         "amount": 600000,
                      //         "installment": {"count": 3, "interval": "month"},
                      //         "card_data": {
                      //           "account_number": "4000000000001091",
                      //           "exp_month": "10",
                      //           "exp_year": "2023",
                      //           "cvn": "123"
                      //         },
                      //         "id_carts": [99732],
                      //         "card_cvn": "123",
                      //         "authentication_id": "m166sylPjHP7DrNntfD0"
                      //       }))),
                      //       headers: {
                      //         'Content-Type': 'application/json',
                      //         'Authorization':
                      //             'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzAiLCJ1c2VyX3ByaXZpbGVnZSI6IjQiLCJ1c2VyX3ZlcnNpb24iOiIyIiwidXNlcl9uYW1lIjoidG9uaXByYXMiLCJzdWIiOjMwLCJleHAiOjE2OTE3NDY3NjMsImlhdCI6MTY5MTc0MzE2M30.kdGFyB-eWT8GGZGvnVsjEKpV6rjy3vnJoqRQgZBLRws'
                      //       }),
                      //   onWebViewCreated: (controller) async {
                      //     // _webViewCtrl.complete(controller);
                      //     controller.loadUrl(
                      //         urlRequest: URLRequest(
                      //             url: Uri.parse(
                      //                 'https://google.com')));

                      //     //  .loadUrl(
                      //     //     Uri.dataFromString(_loadHTML, mimeType: 'text/html')
                      //     //         .toString());
                      //   },
                      // )

                      WebView(
                    debuggingEnabled: false,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: <JavascriptChannel>{
                      JavascriptChannel(
                        name: 'MidtransInvoker',
                        onMessageReceived: (JavascriptMessage jsMsg) {
                          var responseJSON = jsonDecode(jsMsg.message);
                          if (responseJSON['transaction_status'] == 'capture' &&
                              responseJSON['fraud_status'] == 'accept') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThanksPage(
                                  orderId: '',
                                ),
                              ),
                            );
                          } else {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(responseJSON['status_message']),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                      ),
                      JavascriptChannel(
                        name: 'XenditInvoker',
                        onMessageReceived: (JavascriptMessage jsMsg) {
                          var responseJSON = jsonDecode(jsMsg.message);
                          if (responseJSON['status'] == 'CAPTURED' ||
                              responseJSON['status'] == 'ACTIVE') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThanksPage(
                                  orderId: '',
                                ),
                              ),
                            );
                          } else {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('XEN INVOKER : ${jsMsg.message}'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                      ),
                      JavascriptChannel(
                        name: 'ErrorInvoker',
                        onMessageReceived: (JavascriptMessage jsMsg) {
                          final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(jsMsg.message.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      ),
                    },
                    onWebViewCreated:
                        (WebViewController webViewController) async {
                      _webViewCtrl.complete(webViewController);
                      await webViewController.loadUrl(
                          Uri.dataFromString(_loadHTML, mimeType: 'text/html')
                              .toString());
                    },
                  ),
                ),
              ],
            );
          }
          return Center(
            child: GeneralService().getIconLoading(),
          );
        },
      ),
    );
  }
}
