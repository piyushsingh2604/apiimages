import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';




class PixabayService {
  static const String apiKey = '43424556-4de29c0921a89224412a17d2e';
  static const String apiUrl = 'https://pixabay.com/api/';

  Future<List<Map<String, dynamic>>> fetchImages() async {
    final String apiUrl = 'https://pixabay.com/api/';
    final String apiKey = '43424556-4de29c0921a89224412a17d2e';

    final response = await http.get(Uri.parse('$apiUrl?key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['hits'];
      return List<Map<String, dynamic>>.from(data.map((e) => {
            'imageUrl': e['webformatURL'],
            'likes': e['likes'],
            'views': e['views']
          }));
    } else {
      throw Exception('Failed to load images');
    }
  }
}



class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<Map<String, dynamic>>> _imageList;

  @override
  void initState() {
    super.initState();
    _imageList = PixabayService().fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _imageList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 150,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImagePage(
                          imageUrl: snapshot.data![index]['imageUrl'],
                          likes: snapshot.data![index]['likes'],
                          views: snapshot.data![index]['views'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: snapshot.data![index]['imageUrl'],
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data![index]['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Likes: ${snapshot.data![index]['likes']}',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Views: ${snapshot.data![index]['views']}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final int likes;
  final int views;

  FullScreenImagePage({
    required this.imageUrl,
    required this.likes,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
