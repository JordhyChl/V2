import 'package:flutter/material.dart';
import 'package:gpsid/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Dialogs {
  Future<bool> showLoaderDialog(BuildContext context) async {
    AlertDialog alert = AlertDialog(
      content: getIconLoading(),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  // Future<bool> loadingDialog(BuildContext context) async {
  //   AlertDialog alert = AlertDialog(
  //     insetPadding: const EdgeInsets.symmetric(horizontal: 85),
  //     // backgroundColor: Colors.transparent,
  //     content: SizedBox(
  //       height: 140,
  //       // width: 10,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SizedBox(
  //             height: 120,
  //             width: 50,
  //             child: Stack(
  //               children: [
  //                 // Center(
  //                 //   child: Stack(
  //                 //     children: [Image.asset('assets/logoss.png', height: 52)],
  //                 //   ),
  //                 // ),
  //                 // Center(
  //                 //   child: LoadingAnimationWidget.discreteCircle(
  //                 //     size: 80,
  //                 //     color: blueGradientSecondary2,
  //                 //     secondRingColor: blueGradientSecondary1,
  //                 //     thirdRingColor: whiteColor,
  //                 //   ),
  //                 // )
  //                 Column(
  //                   children: [
  //                     Image.asset('assets/logoss.png', height: 52),
  //                     LoadingAnimationWidget.waveDots(
  //                       size: 50,
  //                       color: blueGradientSecondary2,
  //                       // secondRingColor: blueGradientSecondary1,
  //                       // thirdRingColor: whiteColor,
  //                     )
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //           Text(
  //             AppLocalizations.of(context)!.pleaseWait,
  //             style: bold.copyWith(
  //               fontSize: 10,
  //               color: bluePrimary,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //       // return StatefulBuilder(builder: (context, setState) {
  //       //   return alert;
  //       // });
  //     },
  //   );

  //   await Future.delayed(const Duration(milliseconds: 200));
  //   return true;
  // }

  Future<bool> loadingDialog(BuildContext context) async {
    @override
    StatefulBuilder state = StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/gpsidbaru.png',
              width: 130,
            ),
            LoadingAnimationWidget.waveDots(
              size: 50,
              color: whiteColorDarkMode,
              // secondRingColor: blueGradientSecondary1,
              // thirdRingColor: whiteColor,
            )
          ],
        );
      },
    );
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          decoration:
              BoxDecoration(color: blueGradientSecondary2.withOpacity(0.0)),
          child: state,
        );
      },
    );
    return true;
  }

  Future<bool> hideLoaderDialog(BuildContext context) {
    Navigator.of(context).pop();
    return Future.value(true);
  }
}
