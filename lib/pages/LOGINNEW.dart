// // LOGIN NEW
// // ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, unused_import, depend_on_referenced_packages

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:gpsid/common.dart';
// import 'package:gpsid/model/assetmarker.model.dart';
// import 'package:gpsid/model/bodylogin.model.dart';
// import 'package:gpsid/model/errortrap.model.dart';
// import 'package:gpsid/model/link.model.dart';
// import 'package:gpsid/model/localdata.model.dart';
// import 'package:gpsid/model/login.model.dart';
// import 'package:gpsid/model/message.model.dart';
// import 'package:gpsid/model/rememberme.model.dart';
// import 'package:gpsid/pages/recurringhistory.dart';
// import 'package:gpsid/service/api.dart';
// import 'package:gpsid/service/general.dart';
// import 'package:gpsid/theme.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LoginPage extends StatefulWidget {
//   final bool darkMode;
//   const LoginPage({Key? key, required this.darkMode}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _userNameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isHidden = true;
//   bool wrongUsernamePassword = false;
//   bool rememberMe = false;
//   bool signin = true;

//   @override
//   void initState() {
//     // ignore: todo
//     // TODO: implement initState
//     super.initState();
//     checkPermission();
//     checkRememberMe();
//   }

//   checkRememberMe() async {
//     final res = await GeneralService().readRememberMe();
//     if (res is RememberMe) {
//       rememberMe = true;
//       setState(() {
//         _userNameController.text = res.Username;
//         _passwordController.text = res.Password;
//       });
//     }
//   }

//   checkPermission() async {
//     var status = await Permission.storage.status;
//     var statusLocation = await Permission.location.status;
//     var statusNotif = await Permission.notification.status;
//     // var location = await Permission.location.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }
//     if (!statusLocation.isGranted) {
//       await Permission.location.request();
//     }
//     if (!statusNotif.isGranted) {
//       await Permission.notification.request();
//     }
//     // if (!location.isGranted) {
//     //   await Permission.location.request();
//     // }
//   }

//   @override
//   void dispose() {
//     _userNameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   doLogin() async {
//     setState(() {
//       wrongUsernamePassword = false;
//     });
//     await Dialogs().loadingDialog(context);
//     String fcm = '';
//     fcm = await GeneralService().getFCMToken();
//     final BodyLogin bodyLogin = BodyLogin(
//         username: _userNameController.text.trim(),
//         password: _passwordController.text.trim(),
//         fcmToken: fcm);
//     final _result = await APIService().doLogin(bodyLogin);
//     if (_result is LoginModel) {
//       LocalData _data = LocalData(
//           ID: _result.data.ID,
//           Username: _result.data.Username,
//           Password: _passwordController.text,
//           Fullname: _result.data.Fullname,
//           Phone: _result.data.Phone,
//           Email: _result.data.Email,
//           Addres: _result.data.Addres,
//           CompanyName: _result.data.CompanyName,
//           BranchId: _result.data.BranchId,
//           Privilage: _result.data.Privilage,
//           Token: _result.data.Token,
//           SeenId: _result.data.SeenId,
//           IsGenerated: _result.data.isGenerated,
//           createdAt: _result.data.createdAt);
//       rememberMe
//           ? await GeneralService().writeRememberMe(RememberMe(
//               Username: _userNameController.text,
//               Password: _passwordController.text))
//           : await GeneralService().deleteRememberMe();

//       final res = await GeneralService().readRememberMe();
//       print(json.encode(res));
//       await GeneralService().writeLocalUserStorage(_data);

//       final resultURL = await APIService().getURL();
//       if (resultURL is LinkModel) {
//         // LinkModel url = LinkModel(
//         //     status: resultURL.status,
//         //     message: resultURL.message,
//         //     data: DataLink(
//         //         results: ResultLink(
//         //             callUs: resultURL.data.results.callUs,
//         //             aboutUs: resultURL.data.results.aboutUs,
//         //             faq: resultURL.data.results.faq,
//         //             terms: resultURL.data.results.terms,
//         //             whatsapp: resultURL.data.results.whatsapp)));
//         await GeneralService().writeLocalURL(resultURL);
//       } else {
//         // LinkModel url = LinkModel(
//         //     status: resultURL.status,
//         //     message: resultURL.message,
//         //     data: DataLink(
//         //         results: ResultLink(
//         //             callUs: '',
//         //             aboutUs: '',
//         //             faq: '',
//         //             terms: '',
//         //             whatsapp: '')));
//         await GeneralService().writeLocalURL(resultURL);
//       }
//       await Dialogs().hideLoaderDialog(context);
//       Timer.run(() {
//         Navigator.of(context).pushReplacementNamed("/homepage");
//       });
//     }
//     if (_result is ErrorTrapModel) {
//       await Dialogs().hideLoaderDialog(context);
//       showInfoAlert(context, AppLocalizations.of(context)!.noConnection,
//           AppLocalizations.of(context)!.noConnectionSub);
//       // showInfoAlert(context, AppLocalizations.of(context)!.noConnection, '');
//     } else {
//       if (_result is MessageModel) {
//         if (_result.message == '999') {
//           await Dialogs().hideLoaderDialog(context);
//           setState(() {
//             wrongUsernamePassword = true;
//           });
//         } else {
//           await Dialogs().hideLoaderDialog(context);
//           showInfoAlert(context, _result.message, '');
//         }
//       }
//     }
//   }

//   doLoginDemo() async {
//     await Dialogs().loadingDialog(context);
//     String fcm = '';
//     fcm = await GeneralService().getFCMToken();
//     // _userNameController.text = 'demo';
//     // _passwordController.text = 'superspring';
//     final BodyLogin bodyLogin =
//         BodyLogin(username: 'demo', password: 'superspring', fcmToken: fcm);
//     final _result = await APIService().doLogin(bodyLogin);
//     if (_result is LoginModel) {
//       LocalData _data = LocalData(
//           ID: _result.data.ID,
//           Username: _result.data.Username,
//           Password: bodyLogin.password,
//           Fullname: _result.data.Fullname,
//           Phone: _result.data.Phone,
//           Email: _result.data.Email,
//           Addres: _result.data.Addres,
//           CompanyName: _result.data.CompanyName,
//           BranchId: _result.data.BranchId,
//           Privilage: _result.data.Privilage,
//           Token: _result.data.Token,
//           SeenId: _result.data.SeenId,
//           IsGenerated: _result.data.isGenerated,
//           createdAt: _result.data.createdAt);
//       await GeneralService().writeLocalUserStorage(_data);
//       final resultURL = await APIService().getURL();
//       if (resultURL is LinkModel) {
//         // LinkModel url = LinkModel(
//         //     status: resultURL.status,
//         //     message: resultURL.message,
//         //     data: DataLink(
//         //         results: ResultLink(
//         //             callUs: resultURL.data.results.callUs,
//         //             aboutUs: resultURL.data.results.aboutUs,
//         //             faq: resultURL.data.results.faq,
//         //             terms: resultURL.data.results.terms,
//         //             whatsapp: resultURL.data.results.whatsapp)));
//         await GeneralService().writeLocalURL(resultURL);
//       } else {
//         // LinkModel url = LinkModel(
//         //     status: resultURL.status,
//         //     message: resultURL.message,
//         //     data: DataLink(
//         //         results: ResultLink(
//         //             callUs: '',
//         //             aboutUs: '',
//         //             faq: '',
//         //             terms: '',
//         //             whatsapp: '')));
//         await GeneralService().writeLocalURL(resultURL);
//       }
//       await Dialogs().hideLoaderDialog(context);
//       Timer.run(() {
//         Navigator.of(context).pushReplacementNamed("/homepage");
//       });
//     }
//     if (_result is ErrorTrapModel) {
//       await Dialogs().hideLoaderDialog(context);
//       showInfoAlert(context, '${_result.statusError} ${_result.bodyError}', '');
//     } else {
//       await Dialogs().hideLoaderDialog(context);
//       showInfoAlert(context, _result.message, '');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         bottom: false,
//         top: false,
//         child: SingleChildScrollView(
//           child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topRight,
//                   end: Alignment.centerLeft,
//                   colors: [
//                     widget.darkMode ? whiteCardColor : const Color(0xff77A1E4),
//                     widget.darkMode ? whiteCardColor : const Color(0xff45A4DD),
//                     const Color(0xff0484D0),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   SizedBox(
//                     // padding: const EdgeInsets.only(bottom: 50),
//                     width: double.infinity,
//                     // height: 230,
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 70),
//                         child: Column(
//                           children: [
//                             Image.asset(
//                               'assets/logogpsid.png',
//                               height: 60,
//                             ),
//                             Image.asset(
//                               'assets/superspring.png',
//                               height: 60,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Container(
//                                 height: 48,
//                                 width: MediaQuery.of(context).size.width / 1,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: whiteCardColor,
//                                   border: Border.all(
//                                     width: 1,
//                                     color: whiteCardColor,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           signin == false ? signin = true : {};
//                                         });
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 0),
//                                         child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                               color: signin
//                                                   ? bluePrimary
//                                                   : whiteCardColor,
//                                               border: Border.all(
//                                                 width: 1,
//                                                 color: signin
//                                                     ? bluePrimary
//                                                     : whiteCardColor,
//                                               ),
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 6,
//                                                       horizontal: 50),
//                                               child: Text(
//                                                 'Masuk',
//                                                 style: reguler.copyWith(
//                                                     fontSize: 14,
//                                                     color: !signin
//                                                         ? bluePrimary
//                                                         : whiteColorDarkMode),
//                                               ),
//                                             )),
//                                       ),
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           signin == true ? signin = false : {};
//                                         });
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 0),
//                                         child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                               color: !signin
//                                                   ? bluePrimary
//                                                   : whiteCardColor,
//                                               border: Border.all(
//                                                 width: 1,
//                                                 color: !signin
//                                                     ? bluePrimary
//                                                     : whiteCardColor,
//                                               ),
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 6,
//                                                       horizontal: 50),
//                                               child: Text(
//                                                 'Daftar',
//                                                 style: reguler.copyWith(
//                                                     fontSize: 14,
//                                                     color: signin
//                                                         ? bluePrimary
//                                                         : whiteColorDarkMode),
//                                               ),
//                                             )),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                       height: MediaQuery.of(context).size.height,
//                       decoration: BoxDecoration(
//                           color: whiteColor,
//                           borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               topRight: Radius.circular(12))),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // GradientText('Welcome back!', colors: [blueGradientSecondary1, blueGradientSecondary2], gradientDirection: LinearGradient(colors: []),)
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 20),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   GradientText(
//                                       AppLocalizations.of(context)!.welcomeBack,
//                                       style: bold.copyWith(
//                                         fontSize: 24,
//                                       ),
//                                       gradientType: GradientType.linear,
//                                       colors: [
//                                         blueGradientSecondary2,
//                                         blueGradientSecondary1
//                                       ]),
//                                   Text(
//                                     AppLocalizations.of(context)!
//                                         .signinToContinue,
//                                     style: reguler.copyWith(
//                                       fontSize: 14,
//                                       color: widget.darkMode
//                                           ? whiteColorDarkMode
//                                           : blackSecondary3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text(AppLocalizations.of(context)!.username,
//                                 style: bold.copyWith(
//                                   fontSize: 14,
//                                   color: wrongUsernamePassword
//                                       ? redPrimary
//                                       : blackPrimary,
//                                 )),
//                             const SizedBox(
//                               height: 8,
//                             ),
//                             SizedBox(
//                               width: double.infinity,
//                               child: TextFormField(
//                                 controller: _userNameController,
//                                 style: reguler.copyWith(
//                                   fontSize: 13,
//                                   color: blackPrimary,
//                                 ),
//                                 decoration: InputDecoration(
//                                   fillColor: whiteCardColor,
//                                   filled: true,
//                                   hintText: AppLocalizations.of(context)!
//                                       .insertUsername,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   enabledBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: wrongUsernamePassword
//                                           ? redPrimary
//                                           : blackSecondary3,
//                                     ),
//                                   ),
//                                   focusedBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: wrongUsernamePassword
//                                           ? redPrimary
//                                           : bluePrimary,
//                                     ),
//                                   ),
//                                   hintStyle: reguler.copyWith(
//                                     fontSize: 12,
//                                     color: widget.darkMode
//                                         ? whiteColorDarkMode
//                                         : blackSecondary3,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Text(
//                               AppLocalizations.of(context)!.password,
//                               style: bold.copyWith(
//                                 fontSize: 14,
//                                 color: wrongUsernamePassword
//                                     ? redPrimary
//                                     : blackPrimary,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 8,
//                             ),
//                             SizedBox(
//                               width: double.infinity,
//                               child: TextFormField(
//                                 controller: _passwordController,
//                                 style: reguler.copyWith(
//                                   fontSize: 13,
//                                   color: blackPrimary,
//                                 ),
//                                 onFieldSubmitted: (value) {
//                                   doLogin();
//                                 },
//                                 obscureText: _isHidden,
//                                 obscuringCharacter: '*',
//                                 decoration: InputDecoration(
//                                   fillColor: whiteCardColor,
//                                   // errorText: wrongUsernamePassword
//                                   //     ? 'Username or password not registered'
//                                   //     : '',
//                                   filled: true,
//                                   hintText: AppLocalizations.of(context)!
//                                       .insertPassword,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   enabledBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: wrongUsernamePassword
//                                           ? redPrimary
//                                           : blackSecondary3,
//                                     ),
//                                   ),
//                                   focusedBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: wrongUsernamePassword
//                                           ? redPrimary
//                                           : bluePrimary,
//                                     ),
//                                   ),
//                                   hintStyle: reguler.copyWith(
//                                     fontSize: 12,
//                                     color: widget.darkMode
//                                         ? whiteColorDarkMode
//                                         : blackSecondary3,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 20,
//                                   ),
//                                   suffixIcon: InkWell(
//                                     onTap: _togglePassword,
//                                     child: Icon(
//                                       _isHidden
//                                           ? Icons.visibility_off
//                                           : Icons.visibility,
//                                       color: widget.darkMode
//                                           ? whiteColorDarkMode
//                                           : blackSecondary3,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 wrongUsernamePassword
//                                     ? AppLocalizations.of(context)!
//                                         .wrongUsernamePassword
//                                     : '',
//                                 style: bold.copyWith(
//                                   fontSize: 10,
//                                   color: wrongUsernamePassword
//                                       ? redPrimary
//                                       : blackPrimary,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: wrongUsernamePassword
//                                   ? const EdgeInsets.only(top: 16)
//                                   : const EdgeInsets.only(top: 0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     // width: 150,
//                                     child: Transform.translate(
//                                       offset: const Offset(-10, 0),
//                                       child: Theme(
//                                         data: ThemeData(
//                                             unselectedWidgetColor:
//                                                 blackPrimary),
//                                         child: CheckboxListTile(
//                                           controlAffinity:
//                                               ListTileControlAffinity.leading,
//                                           contentPadding: EdgeInsets.zero,
//                                           title: Transform.translate(
//                                             offset: const Offset(-20, 0),
//                                             child: Text(
//                                               AppLocalizations.of(context)!
//                                                   .rememberMe,
//                                               style: reguler.copyWith(
//                                                 fontSize: 12,
//                                                 color: blackPrimary,
//                                                 // decoration:
//                                                 //     TextDecoration.underline,
//                                               ),
//                                             ),
//                                           ),
//                                           value: rememberMe,
//                                           onChanged: (value) async {
//                                             setState(() {
//                                               rememberMe = value!;
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 120,
//                                     child: InkWell(
//                                       onTap: () => launchUrl(
//                                           Uri.parse(
//                                               'https://forgot.gps.id/password'),
//                                           mode: LaunchMode.externalApplication),
//                                       child: Text(
//                                         AppLocalizations.of(context)!
//                                             .forgotPassword,
//                                         style: reguler.copyWith(
//                                           fontSize: 12,
//                                           color: blackPrimary,
//                                           decoration: TextDecoration.underline,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Align(
//                             //   alignment: Alignment.topRight,
//                             //   child: Text(
//                             //     AppLocalizations.of(context)!.forgotPassword,
//                             //     style: reguler.copyWith(
//                             //       fontSize: 12,
//                             //       color: blackPrimary,
//                             //       decoration: TextDecoration.underline,
//                             //     ),
//                             //   ),
//                             // ),
//                             const SizedBox(
//                               height: 40,
//                             ),
//                             SizedBox(
//                               width: double.infinity,
//                               height: 40,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: greenPrimary,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 // shape: RoundedRectangleBorder(
//                                 //   borderRadius: BorderRadius.circular(12),
//                                 // ),
//                                 // color: greenPrimary,
//                                 onPressed: () {
//                                   doLogin();
//                                 },
//                                 child: Text(
//                                   AppLocalizations.of(context)!.login,
//                                   style: bold.copyWith(
//                                     fontSize: 14,
//                                     color: widget.darkMode
//                                         ? whiteColorDarkMode
//                                         : whiteColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Divider(
//                                     height: 2,
//                                     thickness: 1,
//                                     indent: 0,
//                                     endIndent: 0,
//                                     color: widget.darkMode
//                                         ? whiteColorDarkMode
//                                         : greyColor,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10),
//                                   child: Text(
//                                     'Atau masuk dengan',
//                                     style: reguler.copyWith(
//                                         fontSize: 14,
//                                         color: widget.darkMode
//                                             ? whiteColorDarkMode
//                                             : blackSecondary3),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Divider(
//                                     height: 2,
//                                     thickness: 1,
//                                     indent: 0,
//                                     endIndent: 0,
//                                     color: widget.darkMode
//                                         ? whiteColorDarkMode
//                                         : greyColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10),
//                                   child: Expanded(
//                                     child: OutlinedButton(
//                                       style: OutlinedButton.styleFrom(
//                                         side: BorderSide(
//                                           width: 1,
//                                           color: bluePrimary,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(4),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         doLoginDemo();
//                                       },
//                                       child: Text(
//                                         'Akun Demo',
//                                         style: reguler.copyWith(
//                                           fontSize: 14,
//                                           color: bluePrimary,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10),
//                                   child: Expanded(
//                                     child: OutlinedButton(
//                                       style: OutlinedButton.styleFrom(
//                                         side: BorderSide(
//                                           width: 1,
//                                           color: bluePrimary,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(4),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         doLoginDemo();
//                                       },
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceAround,
//                                         children: [
//                                           Image.asset(
//                                             'assets/icon/google.png',
//                                             width: 24,
//                                             height: 24,
//                                           ),
//                                           Text(
//                                             'Google',
//                                             style: reguler.copyWith(
//                                               fontSize: 14,
//                                               color: bluePrimary,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // Padding(
//                             //   padding: const EdgeInsets.only(top: 25),
//                             //   child: Align(
//                             //     alignment: Alignment.center,
//                             //     child: Image.asset(
//                             //       'assets/logosuperspring.png',
//                             //       width: 200,
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ))
//                 ],
//               )),
//         ),
//       ),
//     );
//   }

//   _togglePassword() {
//     setState(() {
//       _isHidden = !_isHidden;
//     });
//   }
// }
