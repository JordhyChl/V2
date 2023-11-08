// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/npwp.model.dart';
import 'package:gpsid/theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TaxInvoiceView extends StatefulWidget {
  final String npwpno;
  final String npwpname;
  final String npwpaddr;
  final String npwpemail;
  final String npwpwa;
  final String npwpstatus;
  const TaxInvoiceView(
      {Key? key,
      required this.npwpno,
      required this.npwpname,
      required this.npwpaddr,
      required this.npwpemail,
      required this.npwpwa,
      required this.npwpstatus})
      : super(key: key);

  @override
  State<TaxInvoiceView> createState() => _TaxInvoiceState();
}

class _TaxInvoiceState extends State<TaxInvoiceView> {
  final TextEditingController taxNumber = TextEditingController();
  final TextEditingController taxOwner = TextEditingController();
  final TextEditingController taxAddress = TextEditingController();
  final TextEditingController whatsAppNum = TextEditingController();
  final TextEditingController email = TextEditingController();
  // late Future<dynamic> _getNPWP;
  late NPWPListModel npwp;
  var maskFormatterNPWP = MaskTextInputFormatter(
      mask: '##.###.###.#-###.###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  var maskFormatterPhone = MaskTextInputFormatter(
      mask: '+62 ####-####-###',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: '+62',
      type: MaskAutoCompletionType.lazy);

  // @override
  // void dispose() {
  //   taxNumber.dispose();
  //   taxOwner.dispose();
  //   taxAddress.dispose();
  //   whatsAppNum.dispose();
  //   email.dispose();
  //   super.dispose();
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _getNPWP = getNPWP();
  // }

  // Future<dynamic> getNPWP() async {
  //   LocalData localData = await GeneralService().readLocalUserStorage();
  //   final result = await APIService().getNPWP(localData.Username, 'portal');
  //   if (result is ErrorTrapModel) {
  //     showInfoAlert(context, result.statusError, '');
  //   } else {
  //     print(result);
  //     if (result is NPWPmodel) {
  //       setState(() {
  //         taxNumber.text = maskFormatterNPWP.maskText(result.data.npwpNo);
  //         whatsAppNum.text = maskFormatterPhone.maskText(
  //             result.data.npwpWa.startsWith('0')
  //                 ? result.data.npwpWa.replaceFirst('0', ' ')
  //                 : result.data.npwpWa);
  //         taxOwner.text = result.data.npwpName;
  //         taxAddress.text = result.data.npwpAddr;
  //         email.text = result.data.npwpEmail;
  //       });
  //     }
  //   }
  //   return result;
  // }

  // editNPWP(String username, String npwpNo, String npwpName, String npwpAddress,
  //     String npwpWA, String npwpEmail) async {
  //   await Dialogs().loadingDialog(context);
  //   final res = await APIService()
  //       .editNPWP(username, npwpNo, npwpName, npwpAddress, npwpWA, npwpEmail);
  //   if (res is ErrorTrapModel) {
  //     Navigator.of(context).pop();
  //     showInfoAlert(context, res.statusError, res.bodyError);
  //   } else {
  //     if (res is MessageModel) {
  //       Navigator.of(context).pop();
  //       showInfoAlert(context, res.message, '');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // size = MediaQuery.of(context).size;
    // width = size.width;
    // height = size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                blueGradientSecondary1,
                blueGradientSecondary2,
              ],
            ),
          ),
        ),
        leading: IconButton(
          iconSize: 32,
          // padding: const EdgeInsets.only(top: 20),
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.taxInvoice,
          style: bold.copyWith(
            fontSize: 16,
            color: whiteColor,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalizations.of(context)!.taxNumber,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(maskFormatterNPWP.maskText(widget.npwpno),
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalizations.of(context)!.ownerName,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(widget.npwpname,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalizations.of(context)!.taxAddress,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(widget.npwpaddr,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalizations.of(context)!.waNumber,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(maskFormatterPhone.maskText(widget.npwpwa),
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(AppLocalizations.of(context)!.email,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(widget.npwpemail,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: blackPrimary,
                            )),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: Container(
      //     padding: const EdgeInsets.symmetric(
      //       horizontal: 10.0,
      //     ),
      //     width: double.infinity,
      //     height: 80.0,
      //     child: Align(
      //       alignment: Alignment.bottomCenter,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Divider(
      //             height: 2,
      //             thickness: 1,
      //             indent: 0,
      //             endIndent: 0,
      //             color: greyColor,
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               SizedBox(
      //                 width: MediaQuery.of(context).size.width / 3,
      //                 child: ElevatedButton(
      //                   onPressed: () {
      //                     Navigator.pop(context);
      //                     // _doSubmit(_portalProfileModel.id);
      //                     // if (_formEdit.currentState.validate()) {
      //                     //   _doSubmit(_portalProfileModel.id);
      //                     // }
      //                   },
      //                   style: ElevatedButton.styleFrom(
      //                       backgroundColor: whiteColor,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(10.0),
      //                         side: BorderSide(color: blueGradient, width: 1),
      //                       ),
      //                       textStyle: const TextStyle(
      //                         color: Colors.white,
      //                       )),
      //                   // shape: RoundedRectangleBorder(
      //                   //   borderRadius: new BorderRadius.circular(10.0),
      //                   //   side: BorderSide(
      //                   //     color: Theme.of(context).accentColor,
      //                   //   ),
      //                   // ),
      //                   // color: Theme.of(context).accentColor,
      //                   // textColor: Colors.white,
      //                   child: Text(
      //                     AppLocalizations.of(context)!.cancel,
      //                     style: TextStyle(
      //                       color: blueGradient,
      //                       fontSize: 14,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               const SizedBox(
      //                 width: 10,
      //               ),
      //               SizedBox(
      //                 width: MediaQuery.of(context).size.width / 2,
      //                 child: ElevatedButton(
      //                   onPressed: () async {
      //                     LocalData local =
      //                         await GeneralService().readLocalUserStorage();
      //                     print(
      //                         'npwp: ${maskFormatterNPWP.unmaskText(taxNumber.text)} || owner: ${taxOwner.text} || address: ${taxAddress.text} || whatsapp: 0${maskFormatterPhone.unmaskText(whatsAppNum.text)} || email: ${email.text}');
      //                     editNPWP(
      //                         local.Username,
      //                         maskFormatterNPWP.unmaskText(taxNumber.text),
      //                         taxOwner.text,
      //                         taxAddress.text,
      //                         '0${maskFormatterPhone.unmaskText(whatsAppNum.text)}',
      //                         email.text);
      //                     // _doSubmit(_portalProfileModel.id);
      //                     // if (_formEdit.currentState.validate()) {
      //                     //   _doSubmit(_portalProfileModel.id);
      //                     // }
      //                   },
      //                   style: ElevatedButton.styleFrom(
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(10.0),
      //                         side: BorderSide(
      //                           color: Theme.of(context).colorScheme.secondary,
      //                         ),
      //                       ),
      //                       backgroundColor:
      //                           Theme.of(context).colorScheme.secondary,
      //                       textStyle: const TextStyle(
      //                         color: Colors.white,
      //                       )),
      //                   // shape: RoundedRectangleBorder(
      //                   //   borderRadius: new BorderRadius.circular(10.0),
      //                   //   side: BorderSide(
      //                   //     color: Theme.of(context).accentColor,
      //                   //   ),
      //                   // ),
      //                   // color: Theme.of(context).accentColor,
      //                   // textColor: Colors.white,
      //                   child: Text(
      //                     AppLocalizations.of(context)!.useTaxInvoice,
      //                     style: const TextStyle(
      //                       fontSize: 14,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     )),
    );
  }
}
