import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail.dart'; // PlantDetailPage'i içeren dosya

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favoritePlants = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePlantsJson =
        prefs.getStringList('favoritePlants') ?? [];
    setState(() {
      favoritePlants = favoritePlantsJson
          .map((plant) => Map<String, dynamic>.from(json.decode(plant)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: favoritePlants.isEmpty
          ? Center(child: Text('No favorite plants yet.'))
          : ListView.builder(
              itemCount: favoritePlants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: favoritePlants[index]['image_url'] as String? ??
                        'https://via.placeholder.com/50x50',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  title: Text(favoritePlants[index]['common_name'] as String? ??
                      'Unknown'),
                  subtitle: Text(
                      favoritePlants[index]['scientific_name'] as String? ??
                          'Unknown'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlantDetailPage(plant: favoritePlants[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
