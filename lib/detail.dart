import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlantDetailPage extends StatefulWidget {
  final Map<String, dynamic> plant;

  PlantDetailPage({required this.plant});

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = prefs.getBool(widget.plant['id'].toString()) ?? false;
    });
  }

  _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      prefs.setBool(widget.plant['id'].toString(), isFavorite);
    });

    // Update the list of favorite plants
    List<String> favoritePlants = prefs.getStringList('favoritePlants') ?? [];
    if (isFavorite) {
      favoritePlants.add(json.encode(widget.plant));
    } else {
      favoritePlants.removeWhere(
          (plant) => json.decode(plant)['id'] == widget.plant['id']);
    }
    prefs.setStringList('favoritePlants', favoritePlants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant['common_name'] as String? ?? 'Plant Details'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CachedNetworkImage(
              imageUrl: widget.plant['image_url'] as String? ??
                  'https://via.placeholder.com/300x200',
              height: 300,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Scientific Classification', [
                    _buildInfoRow('Scientific Name',
                        widget.plant['scientific_name'] as String?),
                    _buildInfoRow('Family', widget.plant['family'] as String?),
                    _buildInfoRow('Genus', widget.plant['genus'] as String?),
                    _buildInfoRow(
                        'Species', widget.plant['species'] as String?),
                  ]),
                  SizedBox(height: 16),
                  _buildInfoSection('Additional Information', [
                    _buildInfoRow(
                        'Common Name', widget.plant['common_name'] as String?),
                    _buildInfoRow(
                        'Year', (widget.plant['year'] as int?)?.toString()),
                    _buildInfoRow('Author', widget.plant['author'] as String?),
                  ]),
                  SizedBox(height: 16),
                  _buildInfoSection('Plant Characteristics', [
                    _buildInfoRow(
                        'Duration', _getListAsString(widget.plant['duration'])),
                    _buildInfoRow(
                        'Edible',
                        (widget.plant['edible'] as bool?) == true
                            ? 'Yes'
                            : 'No'),
                    _buildInfoRow(
                        'Vegetable',
                        (widget.plant['vegetable'] as bool?) == true
                            ? 'Yes'
                            : 'No'),
                  ]),
                  SizedBox(height: 16),
                  if (widget.plant['bibliography'] != null)
                    _buildInfoSection('Bibliography', [
                      Text(widget.plant['bibliography'] as String? ?? '',
                          style: TextStyle(fontSize: 14)),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Unknown'),
          ),
        ],
      ),
    );
  }

  String _getListAsString(dynamic value) {
    if (value == null) return 'Unknown';
    if (value is List) return value.join(', ');
    return value.toString();
  }
}
