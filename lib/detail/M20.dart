// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gpsid/model/fitur.dart';
import 'package:gpsid/model/pemasangan.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/bottom_detail_bar.dart';
import 'package:gpsid/widgets/fiturcard.dart';
import 'package:gpsid/widgets/pemasangancard.dart';

class M20Page extends StatefulWidget {
  const M20Page({Key? key}) : super(key: key);

  @override
  State<M20Page> createState() => _M20PageState();
}

class _M20PageState extends State<M20Page> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _appBar(context),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 320,
            child: TabBarView(
              controller: tabController,
              children: [
                Image.asset('assets/detail1.png'),
                Image.asset('assets/m20detail.png'),
                Image.asset('assets/detail1.png'),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: TabBar(
              labelColor: bluePrimary,
              labelStyle: bold.copyWith(
                fontSize: 16,
                color: bluePrimary,
              ),
              unselectedLabelColor: greyColor,
              controller: tabController,
              tabs: const [
                Tab(
                  text: 'Deskripsi',
                ),
                Tab(
                  text: 'Fitur',
                ),
                Tab(
                  text: 'Pemasangan',
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 369,
            child: TabBarView(
              controller: tabController,
              children: [
                _deskripsi(),
                _fitur(),
                _pemasangan(),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: const BottomDetailBar(),
    );
  }
}

_appBar(context) {
  return AppBar(
    leading: GestureDetector(
      onTap: (() => Navigator.pop(context)),
      child: const Icon(Icons.arrow_back),
    ),
    title: Text(
      'M20 (PORTABLE)',
      style: bold.copyWith(
        fontSize: 18,
      ),
    ),
    backgroundColor: bluePrimary,
  );
}

// Deskripsi Tabs
_deskripsi() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
      'Supersring M20 adalah alat pelacak kendaraan/asset bergerak portable (tanpa kabel) terbaik yang didesain khusus menggunakan magnet yang sangat kuat dan tertanam di bagian dalam GPS Tracker Superspring M20, sehingga pemasangannya menjadi sangat mudah juga sangat rahasia karena anda hanya perlu menempelkan GPS Tracker tersebut ke bagian body kendaraan/container (besi) anda tanpa perlu menggunakan kabel. ',
      style: reguler.copyWith(
        fontSize: 15,
        color: blackSecondary2,
      ),
    ),
  );
}

// Fitur Tabs
_fitur() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 18,
      ),
      child: Column(
        children: [
          FiturCard(
            Fitur(
              imageUrl: 'assets/map.png',
              title: 'Lacak posisi kendaraan',
              desc:
                  'Lacak posisi kendaraan anda secara langung melalui\naplikasi GPS ID',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/portable.png',
              title: 'Portable',
              desc: 'GPS bisa ditempatkan sesuai keperluan pengguna',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/call.png',
              title: 'Dengar percakapan dalam kabin',
              desc: 'Anda dapat mendengarkan percakapan dalam kabin',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FiturCard(
            Fitur(
              imageUrl: 'assets/magnet.png',
              title: 'Magnet kuat',
              desc:
                  'Memiliki magnet yang kuat sehingga bisa\nditempelkan saja pada bidang yang sesuai',
            ),
          ),
        ],
      ),
    ),
  );
}

//Pemasangan Tabs
_pemasangan() {
  return Column(
    children: [
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/mobil.png',
          name: 'Kendaraan roda empat',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/motor.png',
          name: 'Sepeda motor',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/bis.png',
          name: 'Truk/Bus',
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Divider(
        height: 5,
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: whiteCardColor,
      ),
      const SizedBox(
        height: 10,
      ),
      PemasanganCard(
        Pemasangan(
          imageUrl: 'assets/truk.png',
          name: 'Container dan kendaraan lainnya',
        ),
      ),
    ],
  );
}
