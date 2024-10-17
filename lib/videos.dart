import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Videos',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: VideosScreen(),
    );
  }
}

class VideosScreen extends StatefulWidget {
  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;
  String errorMessage = '';
  final String apiKey =
      'k8g38P38WizgZxQtcpRvo1Gh635QqtxETSWrcU5zZ9l2h82S0pN454U2'; // Pexels API anahtarınız

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.pexels.com/videos/search?query=plants&per_page=30'),
        headers: {'Authorization': apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos = data['videos'];
        });
      } else {
        throw Exception('Failed to load videos');
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
        title: Text('Plant Videos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Stack(
                  children: [
                    PageView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        return VideoItem(video: videos[index]);
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildPageIndicator(videos.length),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}

class VideoItem extends StatefulWidget {
  final Map<String, dynamic> video;

  VideoItem({required this.video});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(widget.video['video_files'][0]['link']);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Chewie(
            controller: _chewieController,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video['user']['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.video['url'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
