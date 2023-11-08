// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ComingSoonPage extends StatefulWidget {
  final Map<String, dynamic> responseJSON;

  const ComingSoonPage({Key? key, required this.responseJSON})
      : super(key: key);
  @override
  _ComingSoonPageState createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  @override
  Widget build(BuildContext context) {
    var jsonRes = widget.responseJSON;

    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/bg_home.png',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/500error.png',
                    width: MediaQuery.of(context).size.width * (80 / 100),
                    // fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    'Coming soon',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: (jsonRes['transaction_status'] == 'pending'),
                    // visible: (_jsonRes['payment_type'] == 'bank_transfer' ||
                    //         _jsonRes['payment_type'] == 'cstore')
                    //     ? true
                    //     : false,
                    child: const Text(
                      'Please complete your payment process',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // ElevatedButton(
                  //   onPressed: () => Navigator.of(context).pop(),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: blueGradient,
                  //   ),
                  //   child: Text(
                  //     'Back to Home',
                  //     style: Theme.of(context).textTheme.subtitle2,
                  //   ),
                  // )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
