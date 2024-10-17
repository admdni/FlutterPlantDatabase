import 'package:cardslotgames/categories.dart';
import 'package:cardslotgames/favorite.dart';
import 'package:cardslotgames/photos.dart';
import 'package:cardslotgames/videos.dart';
import 'package:flutter/material.dart';
import 'package:cardslotgames/detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardslotgames/bottom_nav_bar.dart';

import 'home.dart';

void main() => runApp(PlantsApp());

class PlantsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trefle Plants Database',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_bottomNavIndex),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideosScreen(),
                ));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        activeIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return CategoriesScreen();
      case 2:
        return FavoritesScreen();
      case 3:
        return PhotosScreen();
      default:
        return HomePage();
    }
  }
}
