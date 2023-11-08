import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @hello.
  ///
  /// In id, this message translates to:
  /// **'Halo'**
  String get hello;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @demo.
  ///
  /// In id, this message translates to:
  /// **'Gunakan akun demo'**
  String get demo;

  /// No description provided for @username.
  ///
  /// In id, this message translates to:
  /// **'Nama pengguna'**
  String get username;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get password;

  /// No description provided for @insertUsername.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama pengguna anda'**
  String get insertUsername;

  /// No description provided for @insertPassword.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi anda'**
  String get insertPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get forgotPassword;

  /// No description provided for @monitorAndViewCondition.
  ///
  /// In id, this message translates to:
  /// **'Pantau & lihat kondisi'**
  String get monitorAndViewCondition;

  /// No description provided for @yourVehicle.
  ///
  /// In id, this message translates to:
  /// **'kendaraan anda'**
  String get yourVehicle;

  /// No description provided for @insertPlate.
  ///
  /// In id, this message translates to:
  /// **'Masukkan plat/nama kendaraan anda'**
  String get insertPlate;

  /// No description provided for @unitStatus.
  ///
  /// In id, this message translates to:
  /// **'Status unit'**
  String get unitStatus;

  /// No description provided for @moving.
  ///
  /// In id, this message translates to:
  /// **'Bergerak'**
  String get moving;

  /// No description provided for @park.
  ///
  /// In id, this message translates to:
  /// **'Parkir'**
  String get park;

  /// No description provided for @stop.
  ///
  /// In id, this message translates to:
  /// **'Berhenti'**
  String get stop;

  /// No description provided for @lost.
  ///
  /// In id, this message translates to:
  /// **'Tidak update'**
  String get lost;

  /// No description provided for @expireSoon.
  ///
  /// In id, this message translates to:
  /// **'Akan Berakhir'**
  String get expireSoon;

  /// No description provided for @expireNow.
  ///
  /// In id, this message translates to:
  /// **'Berakhir'**
  String get expireNow;

  /// No description provided for @totalUnit.
  ///
  /// In id, this message translates to:
  /// **'Jumlah unit'**
  String get totalUnit;

  /// No description provided for @fyi.
  ///
  /// In id, this message translates to:
  /// **'Informasi untukmu'**
  String get fyi;

  /// No description provided for @thankYouForTrustingUs.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih untuk kepercayaan anda kepada kami'**
  String get thankYouForTrustingUs;

  /// No description provided for @packageExpire.
  ///
  /// In id, this message translates to:
  /// **'Sisa Kadaluarsa Paket'**
  String get packageExpire;

  /// No description provided for @checkSubs.
  ///
  /// In id, this message translates to:
  /// **'Cek sisa paket langanan mu disini'**
  String get checkSubs;

  /// No description provided for @packageAds.
  ///
  /// In id, this message translates to:
  /// **'Jika ada paket yang ingin jatuh tempo, jangan lupa\n perpanjang paket pulsanya yaa, Terima kasih!!'**
  String get packageAds;

  /// No description provided for @seePackage.
  ///
  /// In id, this message translates to:
  /// **'Lihat paket'**
  String get seePackage;

  /// No description provided for @ourProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk kami'**
  String get ourProduct;

  /// No description provided for @detailProduct.
  ///
  /// In id, this message translates to:
  /// **'Detail produk'**
  String get detailProduct;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get seeAll;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua unit'**
  String get all;

  /// No description provided for @listVehicle.
  ///
  /// In id, this message translates to:
  /// **'List Kendaraan'**
  String get listVehicle;

  /// No description provided for @renewSubscription.
  ///
  /// In id, this message translates to:
  /// **'Perbarui berlangganan'**
  String get renewSubscription;

  /// No description provided for @day.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get day;

  /// No description provided for @packageEnds.
  ///
  /// In id, this message translates to:
  /// **'Paket Berakhir'**
  String get packageEnds;

  /// No description provided for @nextPackage.
  ///
  /// In id, this message translates to:
  /// **'Paket Selanjutnya Berakhir'**
  String get nextPackage;

  /// No description provided for @lastUpdate.
  ///
  /// In id, this message translates to:
  /// **'Update Terakhir'**
  String get lastUpdate;

  /// No description provided for @subscriptionEnded.
  ///
  /// In id, this message translates to:
  /// **'Akhir berlangganan'**
  String get subscriptionEnded;

  /// No description provided for @showing.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan'**
  String get showing;

  /// No description provided for @ofs.
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get ofs;

  /// No description provided for @gettingLocalData.
  ///
  /// In id, this message translates to:
  /// **'Mengambil data lokal'**
  String get gettingLocalData;

  /// No description provided for @gettingAccountData.
  ///
  /// In id, this message translates to:
  /// **'Mengambil data akun'**
  String get gettingAccountData;

  /// No description provided for @takeAWhile.
  ///
  /// In id, this message translates to:
  /// **'Membutuhkan beberapa saat'**
  String get takeAWhile;

  /// No description provided for @failedGettingAccountData.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil data akun'**
  String get failedGettingAccountData;

  /// No description provided for @redirectToLogin.
  ///
  /// In id, this message translates to:
  /// **'Mengalihkan ke halaman login'**
  String get redirectToLogin;

  /// No description provided for @redirectToHome.
  ///
  /// In id, this message translates to:
  /// **'Mengalihkan ke Beranda'**
  String get redirectToHome;

  /// No description provided for @goToLogin.
  ///
  /// In id, this message translates to:
  /// **'Ke halaman login'**
  String get goToLogin;

  /// No description provided for @checkReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get checkReport;

  /// No description provided for @stopReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan Berhenti'**
  String get stopReport;

  /// No description provided for @parkingReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan Parkir'**
  String get parkingReport;

  /// No description provided for @runningReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan Perjalanan'**
  String get runningReport;

  /// No description provided for @startDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Mulai'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Selesai'**
  String get endDate;

  /// No description provided for @insertStartDate.
  ///
  /// In id, this message translates to:
  /// **'Masukan Tanggal Mulai'**
  String get insertStartDate;

  /// No description provided for @insertEndDate.
  ///
  /// In id, this message translates to:
  /// **'Masukan Tanggal Selesai'**
  String get insertEndDate;

  /// No description provided for @ctrlEngine.
  ///
  /// In id, this message translates to:
  /// **'On/Off Mesin'**
  String get ctrlEngine;

  /// No description provided for @shareLocation.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Lokasi'**
  String get shareLocation;

  /// No description provided for @callCabin.
  ///
  /// In id, this message translates to:
  /// **'Telepon Kabin'**
  String get callCabin;

  /// No description provided for @totalStop.
  ///
  /// In id, this message translates to:
  /// **'Total Berhenti'**
  String get totalStop;

  /// No description provided for @address.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get address;

  /// No description provided for @startParking.
  ///
  /// In id, this message translates to:
  /// **'Mulai Parkir'**
  String get startParking;

  /// No description provided for @doneParking.
  ///
  /// In id, this message translates to:
  /// **'Selesai Parkir'**
  String get doneParking;

  /// No description provided for @totalParking.
  ///
  /// In id, this message translates to:
  /// **'Total Parkir'**
  String get totalParking;

  /// No description provided for @selectAll.
  ///
  /// In id, this message translates to:
  /// **'Pilih semua'**
  String get selectAll;

  /// No description provided for @addCart.
  ///
  /// In id, this message translates to:
  /// **'Tambah keranjang'**
  String get addCart;

  /// No description provided for @totalCart.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get totalCart;

  /// No description provided for @unitCart.
  ///
  /// In id, this message translates to:
  /// **'Unit'**
  String get unitCart;

  /// No description provided for @topupCart.
  ///
  /// In id, this message translates to:
  /// **'Keranjang Top up'**
  String get topupCart;

  /// No description provided for @day7.
  ///
  /// In id, this message translates to:
  /// **'7 hari lagi'**
  String get day7;

  /// No description provided for @day30.
  ///
  /// In id, this message translates to:
  /// **'30 hari lagi'**
  String get day30;

  /// No description provided for @day90.
  ///
  /// In id, this message translates to:
  /// **'90 hari lagi'**
  String get day90;

  /// No description provided for @vehicleDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail kendaraan'**
  String get vehicleDetail;

  /// No description provided for @choosePackage.
  ///
  /// In id, this message translates to:
  /// **'Pilihan paket'**
  String get choosePackage;

  /// No description provided for @price.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get price;

  /// No description provided for @expire.
  ///
  /// In id, this message translates to:
  /// **'Kadaluarsa'**
  String get expire;

  /// No description provided for @nextExpire.
  ///
  /// In id, this message translates to:
  /// **'Kadaluarsa selanjutnya'**
  String get nextExpire;

  /// No description provided for @taxInvoice.
  ///
  /// In id, this message translates to:
  /// **'Faktur pajak'**
  String get taxInvoice;

  /// No description provided for @addUnit.
  ///
  /// In id, this message translates to:
  /// **'Tambah unit'**
  String get addUnit;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Pilih metode pembayaran'**
  String get choosePaymentMethod;

  /// No description provided for @totalPrice.
  ///
  /// In id, this message translates to:
  /// **'Total harga'**
  String get totalPrice;

  /// No description provided for @taxNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor NPWP'**
  String get taxNumber;

  /// No description provided for @example.
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get example;

  /// No description provided for @insertTax.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor NPWP anda'**
  String get insertTax;

  /// No description provided for @taxOwner.
  ///
  /// In id, this message translates to:
  /// **'Nama pemilik NPWP'**
  String get taxOwner;

  /// No description provided for @insertTaxOwner.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama pemilik NPWP'**
  String get insertTaxOwner;

  /// No description provided for @taxAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat NPWP'**
  String get taxAddress;

  /// No description provided for @insertTaxAddress.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat NPWP'**
  String get insertTaxAddress;

  /// No description provided for @waNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get waNumber;

  /// No description provided for @insertWANumber.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor WhatsApp anda'**
  String get insertWANumber;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @insertEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email anda'**
  String get insertEmail;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @askTaxInvoice.
  ///
  /// In id, this message translates to:
  /// **'Apakah kamu ingin menggunakan faktur pajak?'**
  String get askTaxInvoice;

  /// No description provided for @useTaxInvoice.
  ///
  /// In id, this message translates to:
  /// **'Gunakan faktur pajak'**
  String get useTaxInvoice;

  /// No description provided for @withoutTaxInvoice.
  ///
  /// In id, this message translates to:
  /// **'Tidak, pilih metode pembayaran'**
  String get withoutTaxInvoice;

  /// No description provided for @emptyTopUpCart.
  ///
  /// In id, this message translates to:
  /// **'Keranjang topup mu masih kosong'**
  String get emptyTopUpCart;

  /// No description provided for @addYourTopUpCart.
  ///
  /// In id, this message translates to:
  /// **'Cari dan tambahkan unit untuk menambahkan paket pulsa'**
  String get addYourTopUpCart;

  /// No description provided for @hourMeter.
  ///
  /// In id, this message translates to:
  /// **'Jam Meter'**
  String get hourMeter;

  /// No description provided for @seeDetails.
  ///
  /// In id, this message translates to:
  /// **'Lihat Detail'**
  String get seeDetails;

  /// No description provided for @second.
  ///
  /// In id, this message translates to:
  /// **'Detik'**
  String get second;

  /// No description provided for @minutes.
  ///
  /// In id, this message translates to:
  /// **'Menit'**
  String get minutes;

  /// No description provided for @hour.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get hour;

  /// No description provided for @bankTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer bank'**
  String get bankTransfer;

  /// No description provided for @virtualAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun virtual'**
  String get virtualAccount;

  /// No description provided for @atmNetwork.
  ///
  /// In id, this message translates to:
  /// **'Jaringan ATM'**
  String get atmNetwork;

  /// No description provided for @instantPayment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran instant'**
  String get instantPayment;

  /// No description provided for @creditCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu Kredit / Recurring'**
  String get creditCard;

  /// No description provided for @miniMarket.
  ///
  /// In id, this message translates to:
  /// **'Mini market'**
  String get miniMarket;

  /// No description provided for @orderDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail pesanan'**
  String get orderDetail;

  /// No description provided for @process.
  ///
  /// In id, this message translates to:
  /// **'Proses'**
  String get process;

  /// No description provided for @from.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get from;

  /// No description provided for @distance.
  ///
  /// In id, this message translates to:
  /// **'Jarak'**
  String get distance;

  /// No description provided for @cardNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor kartu'**
  String get cardNumber;

  /// No description provided for @insertCardNumber.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor kartu kredit anda'**
  String get insertCardNumber;

  /// No description provided for @paymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode pembayaran'**
  String get paymentMethod;

  /// No description provided for @recurringTC.
  ///
  /// In id, this message translates to:
  /// **'Dengan memilih recurring, anda telah menyetujui syarat dan ketentuan yang berlaku. Syarat dan ketentuan dapat berubah sewaktu-waktu'**
  String get recurringTC;

  /// No description provided for @termsAndCondition.
  ///
  /// In id, this message translates to:
  /// **'Syarat dan ketentuan'**
  String get termsAndCondition;

  /// No description provided for @editProfile.
  ///
  /// In id, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @accountOwnerData.
  ///
  /// In id, this message translates to:
  /// **'Data pemilik akun'**
  String get accountOwnerData;

  /// No description provided for @fullName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get fullName;

  /// No description provided for @middlelastName.
  ///
  /// In id, this message translates to:
  /// **'Nama tengah / belakang'**
  String get middlelastName;

  /// No description provided for @insertFullName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama lengkap anda'**
  String get insertFullName;

  /// No description provided for @insertYourMiddleLastName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama tengah / belakang anda'**
  String get insertYourMiddleLastName;

  /// No description provided for @countryCode.
  ///
  /// In id, this message translates to:
  /// **'Kode negara'**
  String get countryCode;

  /// No description provided for @phoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor handphone'**
  String get phoneNumber;

  /// No description provided for @insertYourPhoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor handphone anda'**
  String get insertYourPhoneNumber;

  /// No description provided for @companyInfo.
  ///
  /// In id, this message translates to:
  /// **'Info perusahaan'**
  String get companyInfo;

  /// No description provided for @companyName.
  ///
  /// In id, this message translates to:
  /// **'Nama perusahaan'**
  String get companyName;

  /// No description provided for @insertCompanyName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama perusahaan'**
  String get insertCompanyName;

  /// No description provided for @insertCompanyAddress.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat perusahaan anda'**
  String get insertCompanyAddress;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @paymentSuccess.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil'**
  String get paymentSuccess;

  /// No description provided for @thankYouPayment.
  ///
  /// In id, this message translates to:
  /// **'Terimakasih atas transaksi anda'**
  String get thankYouPayment;

  /// No description provided for @accountInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi akun'**
  String get accountInfo;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @changePass.
  ///
  /// In id, this message translates to:
  /// **'Ubah kata sandi'**
  String get changePass;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @transaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transaction;

  /// No description provided for @topupHist.
  ///
  /// In id, this message translates to:
  /// **'Riwayat top up'**
  String get topupHist;

  /// No description provided for @recurringStatus.
  ///
  /// In id, this message translates to:
  /// **'Status pembayaran berulang'**
  String get recurringStatus;

  /// No description provided for @recurringHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pembayaran berulang'**
  String get recurringHistory;

  /// No description provided for @generalInformation.
  ///
  /// In id, this message translates to:
  /// **'Informasi umum'**
  String get generalInformation;

  /// No description provided for @aboutUs.
  ///
  /// In id, this message translates to:
  /// **'Tentang kami'**
  String get aboutUs;

  /// No description provided for @callUs.
  ///
  /// In id, this message translates to:
  /// **'Hubungi kami'**
  String get callUs;

  /// No description provided for @licenseAndAgreement.
  ///
  /// In id, this message translates to:
  /// **'Lisensi dan perjanjian'**
  String get licenseAndAgreement;

  /// No description provided for @termsandconditionLW.
  ///
  /// In id, this message translates to:
  /// **'Syarat dan ketentuan Lifetime warranty'**
  String get termsandconditionLW;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi Aplikasi'**
  String get appVersion;

  /// No description provided for @oldPassword.
  ///
  /// In id, this message translates to:
  /// **'Password lama'**
  String get oldPassword;

  /// No description provided for @insertOldPassword.
  ///
  /// In id, this message translates to:
  /// **'Masukkan password lama'**
  String get insertOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In id, this message translates to:
  /// **'Password baru'**
  String get newPassword;

  /// No description provided for @insertNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Masukkan password baru'**
  String get insertNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password baru'**
  String get confirmNewPassword;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu Ini'**
  String get thisWeek;

  /// No description provided for @verifyPhone.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi nomor handphone'**
  String get verifyPhone;

  /// No description provided for @insertOTP.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode OTP'**
  String get insertOTP;

  /// No description provided for @otpInfo1.
  ///
  /// In id, this message translates to:
  /// **'One Time Password (OTP) telah di kirim ke nomor ponsel anda'**
  String get otpInfo1;

  /// No description provided for @otpInfo2.
  ///
  /// In id, this message translates to:
  /// **'harap masukkan kode untuk melanjutkan tahap verifikasi'**
  String get otpInfo2;

  /// No description provided for @changePhone.
  ///
  /// In id, this message translates to:
  /// **'Ubah nomor ponsel'**
  String get changePhone;

  /// No description provided for @resendOTP.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang OTP'**
  String get resendOTP;

  /// No description provided for @recurringStatusPage.
  ///
  /// In id, this message translates to:
  /// **'Status pembayaran berulang'**
  String get recurringStatusPage;

  /// No description provided for @recurringPaymentNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor pembayaran berulang'**
  String get recurringPaymentNumber;

  /// No description provided for @package.
  ///
  /// In id, this message translates to:
  /// **'Paket'**
  String get package;

  /// No description provided for @nextPayment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran berikutnya'**
  String get nextPayment;

  /// No description provided for @active.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @notActive.
  ///
  /// In id, this message translates to:
  /// **'Tidak aktif'**
  String get notActive;

  /// No description provided for @transactionDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal transaksi'**
  String get transactionDate;

  /// No description provided for @cart.
  ///
  /// In id, this message translates to:
  /// **'Keranjang'**
  String get cart;

  /// No description provided for @detailRecurringStatus.
  ///
  /// In id, this message translates to:
  /// **'Detail status pembayaran berulang'**
  String get detailRecurringStatus;

  /// No description provided for @paymentInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi pembayaran'**
  String get paymentInfo;

  /// No description provided for @stopRecurring.
  ///
  /// In id, this message translates to:
  /// **'Berhenti pembayaran berulang'**
  String get stopRecurring;

  /// No description provided for @licensePlate.
  ///
  /// In id, this message translates to:
  /// **'Plat nomor'**
  String get licensePlate;

  /// No description provided for @gsmNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor GSM'**
  String get gsmNumber;

  /// No description provided for @unitDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail unit'**
  String get unitDetail;

  /// No description provided for @allStatus.
  ///
  /// In id, this message translates to:
  /// **'Semua Status'**
  String get allStatus;

  /// No description provided for @allDate.
  ///
  /// In id, this message translates to:
  /// **'Semua Tanggal'**
  String get allDate;

  /// No description provided for @sortStatus.
  ///
  /// In id, this message translates to:
  /// **'Urutkan Status'**
  String get sortStatus;

  /// No description provided for @sortDate.
  ///
  /// In id, this message translates to:
  /// **'Urutkan Tanggal'**
  String get sortDate;

  /// No description provided for @success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get success;

  /// No description provided for @lastDay.
  ///
  /// In id, this message translates to:
  /// **'Hari Terakhir'**
  String get lastDay;

  /// No description provided for @chooseDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tanggal'**
  String get chooseDate;

  /// No description provided for @pending.
  ///
  /// In id, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @allDateTopup.
  ///
  /// In id, this message translates to:
  /// **'Semua Tanggal Top Up'**
  String get allDateTopup;

  /// No description provided for @to.
  ///
  /// In id, this message translates to:
  /// **'Sampai'**
  String get to;

  /// No description provided for @gsmnumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor GSM'**
  String get gsmnumber;

  /// No description provided for @numberPlate.
  ///
  /// In id, this message translates to:
  /// **'Plat Nomor'**
  String get numberPlate;

  /// No description provided for @number.
  ///
  /// In id, this message translates to:
  /// **'Nomor'**
  String get number;

  /// No description provided for @orderInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Order'**
  String get orderInfo;

  /// No description provided for @paymentDetail.
  ///
  /// In id, this message translates to:
  /// **'Rincian Pembayaran'**
  String get paymentDetail;

  /// No description provided for @detailUnit.
  ///
  /// In id, this message translates to:
  /// **'Detail Unit'**
  String get detailUnit;

  /// No description provided for @searchVehicle.
  ///
  /// In id, this message translates to:
  /// **'Cari kendaraan'**
  String get searchVehicle;

  /// No description provided for @notAvailable.
  ///
  /// In id, this message translates to:
  /// **'Tidak tersedia'**
  String get notAvailable;

  /// No description provided for @failed.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get failed;

  /// No description provided for @detailtopup.
  ///
  /// In id, this message translates to:
  /// **'Detail Riwayat Top Up'**
  String get detailtopup;

  /// No description provided for @repaymentNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Pembayaran Ulang'**
  String get repaymentNumber;

  /// No description provided for @date.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get date;

  /// No description provided for @alarm.
  ///
  /// In id, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @payment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get payment;

  /// No description provided for @warning.
  ///
  /// In id, this message translates to:
  /// **'Peringantan'**
  String get warning;

  /// No description provided for @activeperiod.
  ///
  /// In id, this message translates to:
  /// **'Masa aktif'**
  String get activeperiod;

  /// No description provided for @lastPosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi terakhir'**
  String get lastPosition;

  /// No description provided for @lastData.
  ///
  /// In id, this message translates to:
  /// **'Data terakhir'**
  String get lastData;

  /// No description provided for @pulsaPackageEnded.
  ///
  /// In id, this message translates to:
  /// **'Paket pulsa berakhir'**
  String get pulsaPackageEnded;

  /// No description provided for @vehiclePosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi kendaraan'**
  String get vehiclePosition;

  /// No description provided for @gpsType.
  ///
  /// In id, this message translates to:
  /// **'Tipe GPS'**
  String get gpsType;

  /// No description provided for @deviceName.
  ///
  /// In id, this message translates to:
  /// **'Nama Perangkat'**
  String get deviceName;

  /// No description provided for @vehicleType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Kendaraan'**
  String get vehicleType;

  /// No description provided for @ownerName.
  ///
  /// In id, this message translates to:
  /// **'Nama Pemilik'**
  String get ownerName;

  /// No description provided for @technician.
  ///
  /// In id, this message translates to:
  /// **'Teknisi Pemasang'**
  String get technician;

  /// No description provided for @year.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get year;

  /// No description provided for @engineNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Mesin'**
  String get engineNumber;

  /// No description provided for @chasNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Rangka'**
  String get chasNumber;

  /// No description provided for @speedLimit.
  ///
  /// In id, this message translates to:
  /// **'Batas Kecepatan'**
  String get speedLimit;

  /// No description provided for @warranty.
  ///
  /// In id, this message translates to:
  /// **'Garansi seumur hidup'**
  String get warranty;

  /// No description provided for @registerDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal registrasi'**
  String get registerDate;

  /// No description provided for @share.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get share;

  /// No description provided for @referralCode.
  ///
  /// In id, this message translates to:
  /// **'Kode Referral'**
  String get referralCode;

  /// No description provided for @point.
  ///
  /// In id, this message translates to:
  /// **'Poin'**
  String get point;

  /// No description provided for @tukar.
  ///
  /// In id, this message translates to:
  /// **'Tukar'**
  String get tukar;

  /// No description provided for @getPoints.
  ///
  /// In id, this message translates to:
  /// **'Cara Mendapatkan Poin'**
  String get getPoints;

  /// No description provided for @lastPointHistory.
  ///
  /// In id, this message translates to:
  /// **'History Poin Terakhir'**
  String get lastPointHistory;

  /// No description provided for @shareLocationDetail.
  ///
  /// In id, this message translates to:
  /// **'Bagikan lokasi kendaraan anda dengan cepat, mudah, dan tepat.'**
  String get shareLocationDetail;

  /// No description provided for @somethingWentWrong.
  ///
  /// In id, this message translates to:
  /// **'Sepertinya sedang ada masalah...'**
  String get somethingWentWrong;

  /// No description provided for @somethingWentWrongSub.
  ///
  /// In id, this message translates to:
  /// **'Kami akan segera memperbaikinya dan coba akses kembali lagi dalam beberapa saat.'**
  String get somethingWentWrongSub;

  /// No description provided for @reportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Maaf, data tidak dapat ditemukan'**
  String get reportEmpty;

  /// No description provided for @reportEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Coba masukan tanggal lainnya.'**
  String get reportEmptySub;

  /// No description provided for @changeEmail.
  ///
  /// In id, this message translates to:
  /// **'Ubah alamat email'**
  String get changeEmail;

  /// No description provided for @currentEmail.
  ///
  /// In id, this message translates to:
  /// **'Email saat ini'**
  String get currentEmail;

  /// No description provided for @newEmail.
  ///
  /// In id, this message translates to:
  /// **'Email baru'**
  String get newEmail;

  /// No description provided for @confirmNewEmail.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi email baru'**
  String get confirmNewEmail;

  /// No description provided for @insertCurrentEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email saat ini'**
  String get insertCurrentEmail;

  /// No description provided for @insertNewEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email baru'**
  String get insertNewEmail;

  /// No description provided for @insertConfirmNewEmail.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi email baru'**
  String get insertConfirmNewEmail;

  /// No description provided for @editEmailContent.
  ///
  /// In id, this message translates to:
  /// **'Email baru kamu akan terganti ketika kamu sudah melakukan verifikasi Email kamu. Silahkan cek Kotak masuk Email kamu setelah klik tombol verifikasi email di bawah ini.'**
  String get editEmailContent;

  /// No description provided for @checkEmailInbox.
  ///
  /// In id, this message translates to:
  /// **' Silahkan cek Kotak masuk Email kamu, dan segera lakukan verifikasi'**
  String get checkEmailInbox;

  /// No description provided for @emailVerificationSend.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Email Sudah Terkirim'**
  String get emailVerificationSend;

  /// No description provided for @emailVerificationSendSub.
  ///
  /// In id, this message translates to:
  /// **'Kami sudah mengirimkan link verifikasi ke alamat email '**
  String get emailVerificationSendSub;

  /// No description provided for @emailVerificationSendSubSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan periksa kotak masuk email anda, dan klik link untuk verifikasi.'**
  String get emailVerificationSendSubSub;

  /// No description provided for @checkSpam.
  ///
  /// In id, this message translates to:
  /// **'Tidak menerima email? Periksa folder spam anda. '**
  String get checkSpam;

  /// No description provided for @or.
  ///
  /// In id, this message translates to:
  /// **'Atau '**
  String get or;

  /// No description provided for @changePhoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Ubah nomor handphone'**
  String get changePhoneNumber;

  /// No description provided for @currentPhoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor saat ini'**
  String get currentPhoneNumber;

  /// No description provided for @newPhoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor baru'**
  String get newPhoneNumber;

  /// No description provided for @phoneNumberContent.
  ///
  /// In id, this message translates to:
  /// **'Kamu akan menerima kode verifikasi OTP melalui WhatsApp di nomor baru Kamu. Untuk keamanan akunmu jangan pernah memberitahu kode ini ke siapapun'**
  String get phoneNumberContent;

  /// No description provided for @otpContent.
  ///
  /// In id, this message translates to:
  /// **'Kode verifikasi telah dikirim melalui WhatsApp ke'**
  String get otpContent;

  /// No description provided for @filterAlarm.
  ///
  /// In id, this message translates to:
  /// **'Filter alarm'**
  String get filterAlarm;

  /// No description provided for @totalData.
  ///
  /// In id, this message translates to:
  /// **'Total data'**
  String get totalData;

  /// No description provided for @startDateTime.
  ///
  /// In id, this message translates to:
  /// **'Jam & tanggal mulai'**
  String get startDateTime;

  /// No description provided for @endDateTime.
  ///
  /// In id, this message translates to:
  /// **'Jam & tanggal akhir'**
  String get endDateTime;

  /// No description provided for @checkOut.
  ///
  /// In id, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @vehicleInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi kendaraan'**
  String get vehicleInfo;

  /// No description provided for @deviceInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi perangkat'**
  String get deviceInfo;

  /// No description provided for @odoMeter.
  ///
  /// In id, this message translates to:
  /// **'Odometer'**
  String get odoMeter;

  /// No description provided for @imei.
  ///
  /// In id, this message translates to:
  /// **'IMEI'**
  String get imei;

  /// No description provided for @vehicleRegistration.
  ///
  /// In id, this message translates to:
  /// **'STNK'**
  String get vehicleRegistration;

  /// No description provided for @pleaseWait.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu sebentar ya...'**
  String get pleaseWait;

  /// No description provided for @expireVehList.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan kadaluarsa'**
  String get expireVehList;

  /// No description provided for @redeemPoin.
  ///
  /// In id, this message translates to:
  /// **'Tukar poin'**
  String get redeemPoin;

  /// No description provided for @emptyData.
  ///
  /// In id, this message translates to:
  /// **'Data kosong'**
  String get emptyData;

  /// No description provided for @totalSSpoin.
  ///
  /// In id, this message translates to:
  /// **'Jumlah SSPoin'**
  String get totalSSpoin;

  /// No description provided for @collectPoin.
  ///
  /// In id, this message translates to:
  /// **'Kumpulkan poinnya'**
  String get collectPoin;

  /// No description provided for @getPrize.
  ///
  /// In id, this message translates to:
  /// **'dapatkan hadiahnya'**
  String get getPrize;

  /// No description provided for @parkreportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan aktivitas parkir pada periode ini.'**
  String get parkreportEmpty;

  /// No description provided for @parkreportEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa mengubah tanggal/jam pencarian untuk menemukan histori parkir kendaraanmu.'**
  String get parkreportEmptySub;

  /// No description provided for @stopreportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan kendaraanmu berhenti pada periode ini.'**
  String get stopreportEmpty;

  /// No description provided for @stopreportEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa mengubah tanggal/jam pencarian untuk menemukan histori berhenti kendaraanmu.'**
  String get stopreportEmptySub;

  /// No description provided for @runningreportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan aktivitas pada periode ini.'**
  String get runningreportEmpty;

  /// No description provided for @runningreportEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa mengubah tanggal/jam pencarian untuk menemukan histori perjalananmu.'**
  String get runningreportEmptySub;

  /// No description provided for @hourmeterreportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan aktivitas pada periode ini.'**
  String get hourmeterreportEmpty;

  /// No description provided for @hourmeterreportEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa mengubah tanggal/jam pencarian untuk menemukan histori perjalananmu.'**
  String get hourmeterreportEmptySub;

  /// No description provided for @noExpire.
  ///
  /// In id, this message translates to:
  /// **'Semua paket langgananmu aktif!'**
  String get noExpire;

  /// No description provided for @noExpireSub.
  ///
  /// In id, this message translates to:
  /// **'Selamat menikmati layanan GPS.id. Kami akan segera memberitahumu apabila paket langgananmu akan segera berakhir.'**
  String get noExpireSub;

  /// No description provided for @searchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Maaf, data yang kamu cari tidak kami temukan 🙁'**
  String get searchEmpty;

  /// No description provided for @searchEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa periksa plat nomor atau nama kendaraanmu lalu ulangi pencarian.'**
  String get searchEmptySub;

  /// No description provided for @emptymoving.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan kendaraanmu yang sedang bergerak.'**
  String get emptymoving;

  /// No description provided for @emptymovingSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa memuat ulang halaman ini untuk melihat status terbaru kendaraanmu.'**
  String get emptymovingSub;

  /// No description provided for @emptyParking.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan kendaranmu yang sedang parkir.'**
  String get emptyParking;

  /// No description provided for @emptyParkingSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa memuat ulang halaman ini untuk melihat status terbaru kendaraanmu.'**
  String get emptyParkingSub;

  /// No description provided for @emptyStop.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan kendaranmu dalam status berhenti.'**
  String get emptyStop;

  /// No description provided for @emptyStopSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa memuat ulang halaman ini untuk melihat status terbaru kendaraanmu.'**
  String get emptyStopSub;

  /// No description provided for @emptyLost.
  ///
  /// In id, this message translates to:
  /// **'Semua status kendaraanmu dalam keadaan aktif!'**
  String get emptyLost;

  /// No description provided for @emptyLostSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa menghubungi customer care 24 jam kami jika menemukan status lost pada kendaraanmu.'**
  String get emptyLostSub;

  /// No description provided for @emptyAll.
  ///
  /// In id, this message translates to:
  /// **'Kendaraanmu belum terdaftar nih.'**
  String get emptyAll;

  /// No description provided for @emptyAllSub.
  ///
  /// In id, this message translates to:
  /// **'Yuk daftarkan kendaraanmu dengan menghubungi customer care 24 jam kami.'**
  String get emptyAllSub;

  /// No description provided for @emptyCart.
  ///
  /// In id, this message translates to:
  /// **'Yah! Keranjang top-up kamu kosong nih.'**
  String get emptyCart;

  /// No description provided for @emptyCartSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa klik tombol di bawah, pilih kendaraan, dan masukkan ke keranjang.'**
  String get emptyCartSub;

  /// No description provided for @error500.
  ///
  /// In id, this message translates to:
  /// **'Kami akan segera kembali!'**
  String get error500;

  /// No description provided for @error500Sub.
  ///
  /// In id, this message translates to:
  /// **'Periksa halaman ini beberapa saat lagi dan klik tombol di bawah untuk memuat ulang halaman.'**
  String get error500Sub;

  /// No description provided for @emptyAlarmNotif.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan alarm aktif pada kendaraanmu.'**
  String get emptyAlarmNotif;

  /// No description provided for @emptyAlarmNotifSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa cek secara berkala halaman ini dan notifikasi yang kami kirimkan untuk status alarm terbaru.'**
  String get emptyAlarmNotifSub;

  /// No description provided for @emptyPaymentNotif.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi di akunmu.'**
  String get emptyPaymentNotif;

  /// No description provided for @emptyPaymentNotifSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa melihat seluruh informasi transaksimu di halaman ini.'**
  String get emptyPaymentNotifSub;

  /// No description provided for @emptyInfoNotif.
  ///
  /// In id, this message translates to:
  /// **'Belum ada informasi terbaru untuk kamu.'**
  String get emptyInfoNotif;

  /// No description provided for @emptyInfoNotifSub.
  ///
  /// In id, this message translates to:
  /// **'Kami akan mengirimkan notifikasi jika ada informasi terbaru.'**
  String get emptyInfoNotifSub;

  /// No description provided for @emptyPromoNotif.
  ///
  /// In id, this message translates to:
  /// **'Saat ini belum ada promo.'**
  String get emptyPromoNotif;

  /// No description provided for @emptyPromoNotifSub.
  ///
  /// In id, this message translates to:
  /// **'Kami akan mengirimkan notifikasi jika ada promo terbaru untuk kamu.'**
  String get emptyPromoNotifSub;

  /// No description provided for @seeAddress.
  ///
  /// In id, this message translates to:
  /// **'Lihat alamat'**
  String get seeAddress;

  /// No description provided for @checkSubscription.
  ///
  /// In id, this message translates to:
  /// **'Periksa paket langganan'**
  String get checkSubscription;

  /// No description provided for @product.
  ///
  /// In id, this message translates to:
  /// **'assets/home/product_in.png'**
  String get product;

  /// No description provided for @checkSubsImg.
  ///
  /// In id, this message translates to:
  /// **'assets/home/checksubs_in.png'**
  String get checkSubsImg;

  /// No description provided for @searchHome.
  ///
  /// In id, this message translates to:
  /// **'assets/home/vehsearch_in.png'**
  String get searchHome;

  /// No description provided for @searchHomeDark.
  ///
  /// In id, this message translates to:
  /// **'assets/home/vehsearch_in_dark.png'**
  String get searchHomeDark;

  /// No description provided for @allProduct.
  ///
  /// In id, this message translates to:
  /// **'Semua produk'**
  String get allProduct;

  /// No description provided for @rememberMe.
  ///
  /// In id, this message translates to:
  /// **'Ingat saya'**
  String get rememberMe;

  /// No description provided for @goodMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get goodNight;

  /// No description provided for @showonGMaps.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan di Google Maps'**
  String get showonGMaps;

  /// No description provided for @trackReplay.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Perjalanan'**
  String get trackReplay;

  /// No description provided for @totalEngineOn.
  ///
  /// In id, this message translates to:
  /// **'Total mesin hidup'**
  String get totalEngineOn;

  /// No description provided for @avgSpeed.
  ///
  /// In id, this message translates to:
  /// **'Rata rata kecepatan'**
  String get avgSpeed;

  /// No description provided for @maxSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan maks.'**
  String get maxSpeed;

  /// No description provided for @driveMilage.
  ///
  /// In id, this message translates to:
  /// **'Jarak tempuh'**
  String get driveMilage;

  /// No description provided for @showAddress.
  ///
  /// In id, this message translates to:
  /// **'Lihat alamat'**
  String get showAddress;

  /// No description provided for @totalMovingTime.
  ///
  /// In id, this message translates to:
  /// **'Total waktu bergerak'**
  String get totalMovingTime;

  /// No description provided for @totalPakingTime.
  ///
  /// In id, this message translates to:
  /// **'Total waktu parkir'**
  String get totalPakingTime;

  /// No description provided for @totalStopTime.
  ///
  /// In id, this message translates to:
  /// **'Total waktu berhenti'**
  String get totalStopTime;

  /// No description provided for @orderId.
  ///
  /// In id, this message translates to:
  /// **'ID Pemesanan'**
  String get orderId;

  /// No description provided for @mapStyle.
  ///
  /// In id, this message translates to:
  /// **'Tampilan peta'**
  String get mapStyle;

  /// No description provided for @defaultMap.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get defaultMap;

  /// No description provided for @satelliteMap.
  ///
  /// In id, this message translates to:
  /// **'Satelit'**
  String get satelliteMap;

  /// No description provided for @mapDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail peta'**
  String get mapDetail;

  /// No description provided for @streetView.
  ///
  /// In id, this message translates to:
  /// **'Street View'**
  String get streetView;

  /// No description provided for @trafficView.
  ///
  /// In id, this message translates to:
  /// **'Lalu lintas'**
  String get trafficView;

  /// No description provided for @poiView.
  ///
  /// In id, this message translates to:
  /// **'POI'**
  String get poiView;

  /// No description provided for @engineOnOffConfirm.
  ///
  /// In id, this message translates to:
  /// **'Anda yakin ingin mematikan/hidupkan mesin?'**
  String get engineOnOffConfirm;

  /// No description provided for @engineOnOffConfirmSub.
  ///
  /// In id, this message translates to:
  /// **'Demi keselamatan, untuk mematikan mesin. Mesin akan mati jika kecepatan kendaraan dibawah 20km/h'**
  String get engineOnOffConfirmSub;

  /// No description provided for @engineOnGPRS.
  ///
  /// In id, this message translates to:
  /// **'Hidupkan mesin (GPRS)'**
  String get engineOnGPRS;

  /// No description provided for @engineOffGPRS.
  ///
  /// In id, this message translates to:
  /// **'Matikan mesin (GPRS)'**
  String get engineOffGPRS;

  /// No description provided for @engineOnSMS.
  ///
  /// In id, this message translates to:
  /// **'Hidupkan mesin (SMS)'**
  String get engineOnSMS;

  /// No description provided for @engineOffSMS.
  ///
  /// In id, this message translates to:
  /// **'Matikan mesin (SMS)'**
  String get engineOffSMS;

  /// No description provided for @commandFailed.
  ///
  /// In id, this message translates to:
  /// **'Command gagal!'**
  String get commandFailed;

  /// No description provided for @engineOnCommandSuccess.
  ///
  /// In id, this message translates to:
  /// **'Sukses! Silahkan coba nyalakan mesin kendaraan Anda.'**
  String get engineOnCommandSuccess;

  /// No description provided for @engineOnCommandFailed.
  ///
  /// In id, this message translates to:
  /// **'Maaf, perintah nyalakan mesin via GPRS gagal.'**
  String get engineOnCommandFailed;

  /// No description provided for @engineOnCommandFailedSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa coba nyalakan mesin dengan mengirimkan SMS melalui nomor terdaftar.'**
  String get engineOnCommandFailedSub;

  /// No description provided for @engineOffCommandSuccess.
  ///
  /// In id, this message translates to:
  /// **'Sukses! Mesin kendaraanmu telah dimatikan.'**
  String get engineOffCommandSuccess;

  /// No description provided for @engineOffCommandSuccessSub.
  ///
  /// In id, this message translates to:
  /// **'Mesin kendaraanmu akan berhenti apabila kecepatan kendaraan dibawah 20KM per jam.'**
  String get engineOffCommandSuccessSub;

  /// No description provided for @engineOffCommandFailed.
  ///
  /// In id, this message translates to:
  /// **'Maaf, perintah mematikan mesin via GPRS gagal.'**
  String get engineOffCommandFailed;

  /// No description provided for @engineOffCommandFailedSub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa coba mematikan mesin dengan mengirimkan SMS melalui nomor terdaftar.'**
  String get engineOffCommandFailedSub;

  /// No description provided for @lostTitle.
  ///
  /// In id, this message translates to:
  /// **'Maaf, saat ini data kendaraanmu tidak terupdate 🙁'**
  String get lostTitle;

  /// No description provided for @lostSubTitle.
  ///
  /// In id, this message translates to:
  /// **'Untuk informasi lebih lanjut mengenai kendaraanmu, klik tombol di bawah ini untuk menghubungi customer care 24 jam kami.'**
  String get lostSubTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali!'**
  String get welcomeBack;

  /// No description provided for @signinToContinue.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan'**
  String get signinToContinue;

  /// No description provided for @wrongUsernamePassword.
  ///
  /// In id, this message translates to:
  /// **'Nama pengguna atau Kata sandi tidak terdaftar'**
  String get wrongUsernamePassword;

  /// No description provided for @redeemStatus.
  ///
  /// In id, this message translates to:
  /// **'Status penukaran poin'**
  String get redeemStatus;

  /// No description provided for @redeemCode.
  ///
  /// In id, this message translates to:
  /// **'Kode penukaran'**
  String get redeemCode;

  /// No description provided for @yourSSPoin.
  ///
  /// In id, this message translates to:
  /// **'SSPoin anda'**
  String get yourSSPoin;

  /// No description provided for @redeemSSPoin1.
  ///
  /// In id, this message translates to:
  /// **'Apakah anda yakin akan menukar poin anda dengan'**
  String get redeemSSPoin1;

  /// No description provided for @redeemSSPoin2.
  ///
  /// In id, this message translates to:
  /// **'Poin anda akan dikurangi sebesar'**
  String get redeemSSPoin2;

  /// No description provided for @noConnection.
  ///
  /// In id, this message translates to:
  /// **'Saat ini aplikasi GPS.id tidak dapat terhubung dengan server 🙁'**
  String get noConnection;

  /// No description provided for @noConnectionSub.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi internetmu kemudian muat ulang halaman ini ya.'**
  String get noConnectionSub;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get tryAgain;

  /// No description provided for @redeemNote.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email/no HP/alamat untuk menukar poin'**
  String get redeemNote;

  /// No description provided for @minDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi minimum'**
  String get minDuration;

  /// No description provided for @chooseDuration.
  ///
  /// In id, this message translates to:
  /// **'Pilih durasi minimum'**
  String get chooseDuration;

  /// No description provided for @updateNow.
  ///
  /// In id, this message translates to:
  /// **'Perbarui sekarang'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In id, this message translates to:
  /// **'Lain kali'**
  String get updateLater;

  /// No description provided for @isAvailable.
  ///
  /// In id, this message translates to:
  /// **'kini telah tersedia.'**
  String get isAvailable;

  /// No description provided for @wantUpdate.
  ///
  /// In id, this message translates to:
  /// **'Segera update aplikasimu untuk mengakses beragam fitur terbaru.'**
  String get wantUpdate;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan'**
  String get notifications;

  /// No description provided for @selectStartDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal awal'**
  String get selectStartDate;

  /// No description provided for @selectFinishDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal akhir'**
  String get selectFinishDate;

  /// No description provided for @selectStartTime.
  ///
  /// In id, this message translates to:
  /// **'Pilih waktu awal'**
  String get selectStartTime;

  /// No description provided for @selectFinishTime.
  ///
  /// In id, this message translates to:
  /// **'Pilih waktu akhir'**
  String get selectFinishTime;

  /// No description provided for @logStreaming.
  ///
  /// In id, this message translates to:
  /// **'Log Streaming'**
  String get logStreaming;

  /// No description provided for @totalLogStreamingTime.
  ///
  /// In id, this message translates to:
  /// **'Total waktu penggunaan'**
  String get totalLogStreamingTime;

  /// No description provided for @logStreamingEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak menemukan aktivitas streaming pada periode ini.'**
  String get logStreamingEmpty;

  /// No description provided for @logStreamingEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa mengubah tanggal/jam pencarian untuk menemukan log streaming kendaraanmu.'**
  String get logStreamingEmptySub;

  /// No description provided for @liveFrom.
  ///
  /// In id, this message translates to:
  /// **'Perangkat'**
  String get liveFrom;

  /// No description provided for @startStreaming.
  ///
  /// In id, this message translates to:
  /// **'Tanggal mulai'**
  String get startStreaming;

  /// No description provided for @endStreaming.
  ///
  /// In id, this message translates to:
  /// **'Tanggal akhir'**
  String get endStreaming;

  /// No description provided for @errorBusy.
  ///
  /// In id, this message translates to:
  /// **'Perangkatmu sedang sibuk.'**
  String get errorBusy;

  /// No description provided for @errorBusySub.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu beberapa saat dan muat ulang halaman ini, ya!'**
  String get errorBusySub;

  /// No description provided for @errorPushing.
  ///
  /// In id, this message translates to:
  /// **'Yah🙁'**
  String get errorPushing;

  /// No description provided for @errorPushingSub.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data. Mohon tunggu beberapa saat dan muat ulang halaman ini, ya!'**
  String get errorPushingSub;

  /// No description provided for @camera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @showLabel.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan plat'**
  String get showLabel;

  /// No description provided for @hideLabel.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan plat'**
  String get hideLabel;

  /// No description provided for @needHelp.
  ///
  /// In id, this message translates to:
  /// **'Kami siap membantu!'**
  String get needHelp;

  /// No description provided for @needHelpSub.
  ///
  /// In id, this message translates to:
  /// **'Hubungi kami via WhatsApp sekarang'**
  String get needHelpSub;

  /// No description provided for @cc24H.
  ///
  /// In id, this message translates to:
  /// **'Layanan Pelanggan 24-Jam kami'**
  String get cc24H;

  /// No description provided for @installationBranch.
  ///
  /// In id, this message translates to:
  /// **'Kantor tempat Anda memasang GPS'**
  String get installationBranch;

  /// No description provided for @chooseVehicle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kendaraan'**
  String get chooseVehicle;

  /// No description provided for @addToCartSuccess.
  ///
  /// In id, this message translates to:
  /// **'Tambah unit berhasil dimasukkan ke keranjang!'**
  String get addToCartSuccess;

  /// No description provided for @seeCart.
  ///
  /// In id, this message translates to:
  /// **'Lihat keranjang'**
  String get seeCart;

  /// No description provided for @deleteCart.
  ///
  /// In id, this message translates to:
  /// **'Apakah kamu yakin ingin menghapus unit dari keranjang top up?'**
  String get deleteCart;

  /// No description provided for @deleteAllCart.
  ///
  /// In id, this message translates to:
  /// **'Apakah kamu yakin ingin menghapus semua unit dari keranjang top up?'**
  String get deleteAllCart;

  /// No description provided for @deleteCartButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari keranjang'**
  String get deleteCartButton;

  /// No description provided for @cancelDeleteCart.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get cancelDeleteCart;

  /// No description provided for @waitingForPayment.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pembayaran'**
  String get waitingForPayment;

  /// No description provided for @waitingTransaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi menunggu untuk pembayaran'**
  String get waitingTransaction;

  /// No description provided for @finishPaymentIn.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan pembayaran dalam'**
  String get finishPaymentIn;

  /// No description provided for @copy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get copy;

  /// No description provided for @confirmPayment.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi pembayaran'**
  String get confirmPayment;

  /// No description provided for @notRecievePayment.
  ///
  /// In id, this message translates to:
  /// **'Kami belum menerima pembayaranmu'**
  String get notRecievePayment;

  /// No description provided for @notRecievePaymentSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan lakukan pembayaran. Jika anda memiliki pertanyaan, silahkan hubungi kami.'**
  String get notRecievePaymentSub;

  /// No description provided for @seePaymentDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail pembayaran'**
  String get seePaymentDetail;

  /// No description provided for @backToTopup.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke halaman topup'**
  String get backToTopup;

  /// No description provided for @timeoutPayment.
  ///
  /// In id, this message translates to:
  /// **'Waktu pembayaranmu habis'**
  String get timeoutPayment;

  /// No description provided for @timeoutPaymentSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan lakukan transaksi kembali. Jika anda memiliki pertanyaan, silahkan menghubungi kami.'**
  String get timeoutPaymentSub;

  /// No description provided for @topupSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran Top-Up paket GPS.Id berhasil'**
  String get topupSuccess;

  /// No description provided for @topupSuccessSub.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih atas pembayaran anda! Nikmati keunggulan dan manfaat GPS Tracker SUPERSPRING'**
  String get topupSuccessSub;

  /// No description provided for @seeInvoice.
  ///
  /// In id, this message translates to:
  /// **'Lihat invoice'**
  String get seeInvoice;

  /// No description provided for @cancelPaymentTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran dibatalkan'**
  String get cancelPaymentTitle;

  /// No description provided for @cancelPayment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran berhasil dibatalkan'**
  String get cancelPayment;

  /// No description provided for @cancelPaymentSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan lakukan transaksi kembali. Jika anda memiliki pertanyaan, silahkan hubungi kami.'**
  String get cancelPaymentSub;

  /// No description provided for @lang.
  ///
  /// In id, this message translates to:
  /// **'id'**
  String get lang;

  /// No description provided for @successAddedToCart.
  ///
  /// In id, this message translates to:
  /// **'berhasil dimasukkan ke keranjang'**
  String get successAddedToCart;

  /// No description provided for @recurringInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi pembayaran berulang'**
  String get recurringInfo;

  /// No description provided for @noPoinTransaction.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi poin'**
  String get noPoinTransaction;

  /// No description provided for @notificationSetting.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan notifikasi'**
  String get notificationSetting;

  /// No description provided for @claraTitle1.
  ///
  /// In id, this message translates to:
  /// **'Hai'**
  String get claraTitle1;

  /// No description provided for @claraTitle2.
  ///
  /// In id, this message translates to:
  /// **'paket langgananmu akan segera habis nih.'**
  String get claraTitle2;

  /// No description provided for @claraSubTitle.
  ///
  /// In id, this message translates to:
  /// **'Harap segera perpanjang paket berlangganan Anda untuk menjamin kelangsungan layanan pelacakan.'**
  String get claraSubTitle;

  /// No description provided for @claraSevenday.
  ///
  /// In id, this message translates to:
  /// **'akan kadaluarsa dalam 7 Hari'**
  String get claraSevenday;

  /// No description provided for @claraThreeday.
  ///
  /// In id, this message translates to:
  /// **'akan kadaluarsa dalam 3 Hari'**
  String get claraThreeday;

  /// No description provided for @claraExpire.
  ///
  /// In id, this message translates to:
  /// **'sudah kadaluarsa'**
  String get claraExpire;

  /// No description provided for @unit.
  ///
  /// In id, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @units.
  ///
  /// In id, this message translates to:
  /// **'Unit'**
  String get units;

  /// No description provided for @unitTerminated180Title.
  ///
  /// In id, this message translates to:
  /// **'Unit Ini sudah Expired Lebih Dari 180 hari'**
  String get unitTerminated180Title;

  /// No description provided for @unitTerminated180SubTitle.
  ///
  /// In id, this message translates to:
  /// **'Hubungi kami untuk mengganti kartu sim.'**
  String get unitTerminated180SubTitle;

  /// No description provided for @unitTerminated7Title.
  ///
  /// In id, this message translates to:
  /// **'Unit Ini sudah Expired Lebih Dari 7 hari'**
  String get unitTerminated7Title;

  /// No description provided for @unitTerminated7SubTitle.
  ///
  /// In id, this message translates to:
  /// **'Tenang, kamu bisa mengaktifkan kembali dengan menghubungi kami.'**
  String get unitTerminated7SubTitle;

  /// No description provided for @changeTheme.
  ///
  /// In id, this message translates to:
  /// **'Ganti tema'**
  String get changeTheme;

  /// No description provided for @verifEmail.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum melakukan verifikasi email.'**
  String get verifEmail;

  /// No description provided for @verifEmailSub.
  ///
  /// In id, this message translates to:
  /// **'Lakukan verifikasi email, untuk nikmati seluruh layanan GPS.id.'**
  String get verifEmailSub;

  /// No description provided for @completeProfile.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi profil anda.'**
  String get completeProfile;

  /// No description provided for @completeProfileSub.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi informasi akunmu guna mengoptimalkan penggunaan GPS.id.'**
  String get completeProfileSub;

  /// No description provided for @howToCallYou.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana kami dapat menghubungi Anda?'**
  String get howToCallYou;

  /// No description provided for @howToCallYouEmpty.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memilih melalui platform apa kami dapat menghubungi Anda'**
  String get howToCallYouEmpty;

  /// No description provided for @verifEmailButton.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi email'**
  String get verifEmailButton;

  /// No description provided for @phoneNumberHasVerified.
  ///
  /// In id, this message translates to:
  /// **'Nomor Handphone sudah terverifikasi'**
  String get phoneNumberHasVerified;

  /// No description provided for @phoneNumberHasNotVerified.
  ///
  /// In id, this message translates to:
  /// **'Nomor Handphone belum terverifikasi'**
  String get phoneNumberHasNotVerified;

  /// No description provided for @emailHasVerified.
  ///
  /// In id, this message translates to:
  /// **'Email sudah terverifikasi'**
  String get emailHasVerified;

  /// No description provided for @emailHasNotVerified.
  ///
  /// In id, this message translates to:
  /// **'Email belum terverifikasi'**
  String get emailHasNotVerified;

  /// No description provided for @yourEmailHasNotBeenVerified.
  ///
  /// In id, this message translates to:
  /// **'Email anda belum terverifikasi, periksa kotak masuk email anda'**
  String get yourEmailHasNotBeenVerified;

  /// No description provided for @emailVerificationSuccess.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi email berhasil'**
  String get emailVerificationSuccess;

  /// No description provided for @emailVerificationSuccessThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih sudah melakukan verifikasi email, kamu dapat melanjutkan menikmati seluruh layanan GPS.id.'**
  String get emailVerificationSuccessThanks;

  /// No description provided for @emailRegistVerificationSuccessThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih sudah melakukan verifikasi email, kamu dapat lanjut melanjutkan untuk membuat akun GPS.id'**
  String get emailRegistVerificationSuccessThanks;

  /// No description provided for @callForHelp.
  ///
  /// In id, this message translates to:
  /// **'Hubungi bantuan'**
  String get callForHelp;

  /// No description provided for @checkVerificationStatus.
  ///
  /// In id, this message translates to:
  /// **'Cek status verifikasi'**
  String get checkVerificationStatus;

  /// No description provided for @phoneVerificationSuccess.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi nomor handphone berhasil'**
  String get phoneVerificationSuccess;

  /// No description provided for @phoneVerificationSuccessThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih sudah melakukan verifikasi nomor handphone, kamu dapat melanjutkan menikmati seluruh layanan GPS.id.'**
  String get phoneVerificationSuccessThanks;

  /// No description provided for @phoneVerificationSendSub.
  ///
  /// In id, this message translates to:
  /// **'Kami sudah mengirimkan kode OTP ke nomor '**
  String get phoneVerificationSendSub;

  /// No description provided for @phoneVerificationSendSubSub.
  ///
  /// In id, this message translates to:
  /// **'Untuk keamanan akunmu, jangan pernah memberitahu kode ini ke siapapun.'**
  String get phoneVerificationSendSubSub;

  /// No description provided for @otpPleaseWait.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu dalam '**
  String get otpPleaseWait;

  /// No description provided for @otpForResend.
  ///
  /// In id, this message translates to:
  /// **'untuk kirim ulang'**
  String get otpForResend;

  /// No description provided for @verifEmailPhone.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum melakukan verifikasi email & nomor handphone'**
  String get verifEmailPhone;

  /// No description provided for @verifEmailPhoneSub.
  ///
  /// In id, this message translates to:
  /// **'Lakukan verifikasi email dan nomor handphone untuk bisa menggunakan seluruh layanan GPS.id.'**
  String get verifEmailPhoneSub;

  /// No description provided for @verifEmailHome.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum melakukan verifikasi email'**
  String get verifEmailHome;

  /// No description provided for @verifEmailSubHome.
  ///
  /// In id, this message translates to:
  /// **'Lakukan verifikasi email untuk bisa menggunakan seluruh layanan GPS.id.'**
  String get verifEmailSubHome;

  /// No description provided for @verifPhoneHome.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum melakukan verifikasi nomor handphone'**
  String get verifPhoneHome;

  /// No description provided for @verifPhoneSubHome.
  ///
  /// In id, this message translates to:
  /// **'Lakukan verifikasi nomor handphone untuk bisa menggunakan seluruh layanan GPS.id.'**
  String get verifPhoneSubHome;

  /// No description provided for @changeAndVerifEmail.
  ///
  /// In id, this message translates to:
  /// **'Ubah dan verifikasi email'**
  String get changeAndVerifEmail;

  /// No description provided for @changeAndVerifPhone.
  ///
  /// In id, this message translates to:
  /// **'Ubah dan verifikasi nomor handphone'**
  String get changeAndVerifPhone;

  /// No description provided for @done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get done;

  /// No description provided for @updateProfile.
  ///
  /// In id, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @emailRegistTitle.
  ///
  /// In id, this message translates to:
  /// **'Anda akan menerima email untuk verifikasi pendaftaran akun GPS.id'**
  String get emailRegistTitle;

  /// No description provided for @confirmPasswordRegist.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password anda'**
  String get confirmPasswordRegist;

  /// No description provided for @verifYourEmail.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi email anda'**
  String get verifYourEmail;

  /// No description provided for @verifYourEmailSub.
  ///
  /// In id, this message translates to:
  /// **'Untuk menyelesaikan penyiapan akun, Anda perlu memverifikasi email anda.'**
  String get verifYourEmailSub;

  /// No description provided for @verifYourEmailSubSub.
  ///
  /// In id, this message translates to:
  /// **'Kami sudah mengirimkan link verifikasi ke alamat email '**
  String get verifYourEmailSubSub;

  /// No description provided for @verifYourEmailSubSubSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan periksa email anda, dan klik tautan untuk memverifikasi email anda.'**
  String get verifYourEmailSubSubSub;

  /// No description provided for @verifYourEmailSubSubSubSub.
  ///
  /// In id, this message translates to:
  /// **'Tidak menerima email? Periksa folder spam Anda. Atau'**
  String get verifYourEmailSubSubSubSub;

  /// No description provided for @resendEmail.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang email'**
  String get resendEmail;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Selanjutnya'**
  String get next;

  /// No description provided for @title.
  ///
  /// In id, this message translates to:
  /// **'Titel'**
  String get title;

  /// No description provided for @entity.
  ///
  /// In id, this message translates to:
  /// **'Entitas'**
  String get entity;

  /// No description provided for @checkPass.
  ///
  /// In id, this message translates to:
  /// **'Periksa email & password anda'**
  String get checkPass;

  /// No description provided for @passMustBe6.
  ///
  /// In id, this message translates to:
  /// **'Password anda kurang dari 6 karakter'**
  String get passMustBe6;

  /// No description provided for @verifDone.
  ///
  /// In id, this message translates to:
  /// **'Saya sudah verifikasi email'**
  String get verifDone;

  /// No description provided for @imeiRegistered.
  ///
  /// In id, this message translates to:
  /// **'IMEI terdaftar pada database kami'**
  String get imeiRegistered;

  /// No description provided for @imeiNotRegistered.
  ///
  /// In id, this message translates to:
  /// **'IMEI tidak terdaftar pada database kami'**
  String get imeiNotRegistered;

  /// No description provided for @gsmRegistered.
  ///
  /// In id, this message translates to:
  /// **'Nomor GSM terdaftar pada database kami'**
  String get gsmRegistered;

  /// No description provided for @gsmNotRegistered.
  ///
  /// In id, this message translates to:
  /// **'Nomor GSM tidak terdaftar pada database kami'**
  String get gsmNotRegistered;

  /// No description provided for @unitRegister.
  ///
  /// In id, this message translates to:
  /// **'Kamu harus untuk menambahkan minimal 1 Unit GPS.id sebelum melanjutkan.'**
  String get unitRegister;

  /// No description provided for @inputCompanyName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama perusahaan anda'**
  String get inputCompanyName;

  /// No description provided for @mr.
  ///
  /// In id, this message translates to:
  /// **'Tuan'**
  String get mr;

  /// No description provided for @mrs.
  ///
  /// In id, this message translates to:
  /// **'Nyonya'**
  String get mrs;

  /// No description provided for @ms.
  ///
  /// In id, this message translates to:
  /// **'Nona'**
  String get ms;

  /// No description provided for @insertName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama anda'**
  String get insertName;

  /// No description provided for @branch.
  ///
  /// In id, this message translates to:
  /// **'Cabang'**
  String get branch;

  /// No description provided for @createAccount.
  ///
  /// In id, this message translates to:
  /// **'Buat akun'**
  String get createAccount;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @checkIMEI.
  ///
  /// In id, this message translates to:
  /// **'Periksa IMEI'**
  String get checkIMEI;

  /// No description provided for @pleaseCheckIMEI.
  ///
  /// In id, this message translates to:
  /// **'Mohon periksa IMEI anda. Pastikan anda memasukkan IMEI yang benar'**
  String get pleaseCheckIMEI;

  /// No description provided for @checkGSM.
  ///
  /// In id, this message translates to:
  /// **'Periksa nomor GSM'**
  String get checkGSM;

  /// No description provided for @pleaseCheckGSM.
  ///
  /// In id, this message translates to:
  /// **'Mohon periksa nomor GSM anda. Pastikan anda memasukkan nomor GSM yang benar'**
  String get pleaseCheckGSM;

  /// No description provided for @dataIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Data belum lengkap'**
  String get dataIncomplete;

  /// No description provided for @vehicleName.
  ///
  /// In id, this message translates to:
  /// **'Nama kendaraan'**
  String get vehicleName;

  /// No description provided for @insertVehicleName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama kendaraan'**
  String get insertVehicleName;

  /// No description provided for @chooseVehicleType.
  ///
  /// In id, this message translates to:
  /// **'Pilih tipe kendaraan'**
  String get chooseVehicleType;

  /// No description provided for @vehicleIcon.
  ///
  /// In id, this message translates to:
  /// **'Icon kendaraan'**
  String get vehicleIcon;

  /// No description provided for @chooseVehicleIcon.
  ///
  /// In id, this message translates to:
  /// **'Pilih icon kendaraan'**
  String get chooseVehicleIcon;

  /// No description provided for @customerType.
  ///
  /// In id, this message translates to:
  /// **'Tipe konsumen'**
  String get customerType;

  /// No description provided for @individual.
  ///
  /// In id, this message translates to:
  /// **'Individu'**
  String get individual;

  /// No description provided for @company.
  ///
  /// In id, this message translates to:
  /// **'Perusahaan'**
  String get company;

  /// No description provided for @registerSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pembuatan akun berhasil'**
  String get registerSuccess;

  /// No description provided for @registerSuccessSub.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih sudah mempercayai kami. Selamat menggunakan layanan dan manfaat dari GPS.id dari Super Spring'**
  String get registerSuccessSub;

  /// No description provided for @noPendingTransaction.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi tertunda'**
  String get noPendingTransaction;

  /// No description provided for @iAgree.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui'**
  String get iAgree;

  /// No description provided for @termsAndConditionSuperspring.
  ///
  /// In id, this message translates to:
  /// **'Syarat, ketentuan dan kebijakan SUPERSPRING'**
  String get termsAndConditionSuperspring;

  /// No description provided for @orLoginWith.
  ///
  /// In id, this message translates to:
  /// **'Atau masuk dengan'**
  String get orLoginWith;

  /// No description provided for @notRegisteredYet.
  ///
  /// In id, this message translates to:
  /// **'Akun anda belum terdaftar'**
  String get notRegisteredYet;

  /// No description provided for @notRegisteredYetSub.
  ///
  /// In id, this message translates to:
  /// **'Silahkan daftar akun menggunakan Google terlebih dahulu'**
  String get notRegisteredYetSub;

  /// No description provided for @deleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun'**
  String get deleteAccount;

  /// No description provided for @differentEmail.
  ///
  /// In id, this message translates to:
  /// **'Email akun anda dan email Google yang anda pilih berbeda'**
  String get differentEmail;

  /// No description provided for @accountConnectedWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Akun anda sudah terhubung dengan Google'**
  String get accountConnectedWithGoogle;

  /// No description provided for @accountConnectedWithApple.
  ///
  /// In id, this message translates to:
  /// **'Akun anda sudah terhubung dengan Apple'**
  String get accountConnectedWithApple;

  /// No description provided for @disconnectGoogle.
  ///
  /// In id, this message translates to:
  /// **'Putus koneksi Google'**
  String get disconnectGoogle;

  /// No description provided for @disconnectApple.
  ///
  /// In id, this message translates to:
  /// **'Putus koneksi Apple'**
  String get disconnectApple;

  /// No description provided for @connectedWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Terhubung dengan '**
  String get connectedWithGoogle;

  /// No description provided for @connectedWithApple.
  ///
  /// In id, this message translates to:
  /// **'Terhubung dengan '**
  String get connectedWithApple;

  /// No description provided for @connectToGoogle.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan dengan Google'**
  String get connectToGoogle;

  /// No description provided for @connectToApple.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan dengan Apple'**
  String get connectToApple;

  /// No description provided for @doYouWantToDeleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Apakah anda yakin ingin menghapus akun GPS.id anda?'**
  String get doYouWantToDeleteAccount;

  /// No description provided for @emptyEmail.
  ///
  /// In id, this message translates to:
  /// **'Email kosong'**
  String get emptyEmail;

  /// No description provided for @wrongEmail.
  ///
  /// In id, this message translates to:
  /// **'Email salah'**
  String get wrongEmail;

  /// No description provided for @checkEmailToDelete.
  ///
  /// In id, this message translates to:
  /// **'Periksa email anda untuk melanjutkan proses hapus akun GPS.id'**
  String get checkEmailToDelete;

  /// No description provided for @deleteYourAccountSuccess.
  ///
  /// In id, this message translates to:
  /// **'Akun anda berhasil dihapus'**
  String get deleteYourAccountSuccess;

  /// No description provided for @notYetDeleteAccountVerif.
  ///
  /// In id, this message translates to:
  /// **'Anda belum melakukan verifikasi penghapusan akun di email anda'**
  String get notYetDeleteAccountVerif;

  /// No description provided for @checkDeleteVerificationStatus.
  ///
  /// In id, this message translates to:
  /// **'Periksa status verifikasi hapus akun'**
  String get checkDeleteVerificationStatus;

  /// No description provided for @registerWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Daftar dengan Google'**
  String get registerWithGoogle;

  /// No description provided for @registerWithApple.
  ///
  /// In id, this message translates to:
  /// **'Daftar dengan Apple'**
  String get registerWithApple;

  /// No description provided for @logInWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get logInWithGoogle;

  /// No description provided for @logInWithApple.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Apple'**
  String get logInWithApple;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In id, this message translates to:
  /// **'Email sudah digunakan. Mohon ganti dan verifikasi terlebih dahulu email akun GPS.id anda sebelum melanjutkan proses koneksi Google'**
  String get emailAlreadyUsed;

  /// No description provided for @accountAlreadyDeleted.
  ///
  /// In id, this message translates to:
  /// **'Akun anda sudah dihapus. Mohon hubungi customer care 24 jam kami untuk melakukan aktivasi ulang akun anda.'**
  String get accountAlreadyDeleted;

  /// No description provided for @howToPay.
  ///
  /// In id, this message translates to:
  /// **'Cara pembayaran'**
  String get howToPay;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
