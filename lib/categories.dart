import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Categories',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CategoriesScreen(),
    );
  }
}

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';
  final String apiKey =
      'hIvLtCtAARMbRpHCYBpyYqVjoovJPaMOC3F0X2pVb3c'; // API anahtarınız

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://trefle.io/api/v1/genus?token=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['data'];
        });
      } else {
        throw Exception('Failed to load categories');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Categories'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) =>
                      CategoryItem(category: categories[i]),
                ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;

  CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantsInCategoryScreen(category: category),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.withOpacity(0.7), Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          category['name'],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class PlantsInCategoryScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  PlantsInCategoryScreen({required this.category});

  @override
  _PlantsInCategoryScreenState createState() => _PlantsInCategoryScreenState();
}

class _PlantsInCategoryScreenState extends State<PlantsInCategoryScreen> {
  List<dynamic> plants = [];
  bool isLoading = true;
  String errorMessage = '';
  final String apiKey =
      'hIvLtCtAARMbRpHCYBpyYqVjoovJPaMOC3F0X2pVb3c'; // API anahtarınız

  @override
  void initState() {
    super.initState();
    fetchPlantsInCategory();
  }

  Future<void> fetchPlantsInCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://trefle.io/api/v1/plants?token=$apiKey&filter[genus_id]=${widget.category['id']}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          plants = data['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category['name']),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (ctx, i) => PlantItem(plant: plants[i]),
                ),
    );
  }
}

class PlantItem extends StatelessWidget {
  final Map<String, dynamic> plant;

  PlantItem({required this.plant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(plant: plant),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    plant['image_url'] ?? 'https://via.placeholder.com/150',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                plant['common_name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantDetailPage extends StatelessWidget {
  final Map<String, dynamic> plant;

  PlantDetailPage({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant['common_name'] ?? 'Unknown'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: plant['image_url'] ?? 'https://via.placeholder.com/150',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Common Name: ${plant['common_name'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Scientific Name: ${plant['scientific_name'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Family: ${plant['family'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Genus: ${plant['genus'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
