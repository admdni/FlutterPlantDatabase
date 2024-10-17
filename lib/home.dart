import 'package:cardslotgames/detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(PlantsApp());

class PlantsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trefle Plants Database',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> plants = [];
  List<dynamic> filteredPlants = [];
  List<String> categories = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  int page = 1;

  final String apiKey = '';

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://trefle.io/api/v1/plants?token=$apiKey&page=$page'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          plants.addAll(data['data']);
          filteredPlants = plants;
          categories = ['All', ...extractCategories(plants)];
        });
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> extractCategories(List<dynamic> plants) {
    Set<String> uniqueCategories = Set();
    for (var plant in plants) {
      if (plant['family'] != null) {
        uniqueCategories.add(plant['family']);
      }
    }
    return uniqueCategories.toList()..sort();
  }

  void filterPlants(String query) {
    setState(() {
      if (query.isEmpty && selectedCategory == 'All') {
        filteredPlants = plants;
      } else {
        filteredPlants = plants.where((plant) {
          bool matchesSearch = plant['common_name']
                  ?.toLowerCase()
                  .contains(query.toLowerCase()) ??
              false ||
                  plant['scientific_name']
                      .toLowerCase()
                      .contains(query.toLowerCase());
          bool matchesCategory =
              selectedCategory == 'All' || plant['family'] == selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trefle Plants Database'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Image Slider
          if (plants.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: plants.take(5).map((plant) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: plant['image_url'] ??
                                  'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7)
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              plant['common_name'] ?? 'Unknown',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search plants...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: filterPlants,
            ),
          ),
          // Category Chips
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: selectedCategory == categories[index],
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedCategory = categories[index];
                          filterPlants(searchController.text);
                        });
                      }
                    },
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                        color: selectedCategory == categories[index]
                            ? Colors.white
                            : Colors.black),
                  ),
                );
              },
            ),
          ),
          // Plant List
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlants.length + 1,
              itemBuilder: (context, index) {
                if (index < filteredPlants.length) {
                  final plant = filteredPlants[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                          plant['image_url'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(
                        plant['common_name'] ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plant['scientific_name'] ?? '',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(plant['family'] ?? 'Unknown family',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantDetailPage(plant: plant),
                          ),
                        );
                      },
                    ),
                  );
                } else if (!isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      child: Text('Load More'),
                      onPressed: () {
                        page++;
                        fetchPlants();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
