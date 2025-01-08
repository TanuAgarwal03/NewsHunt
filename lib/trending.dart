import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> downloadImageToLocal(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${url.hashCode}.jpg';
    final dio = Dio();
    await dio.download(url, filePath);
    return filePath;
  }

  Future<void> downloadImage(BuildContext context, String imageUrl) async {
    try {
      final filePath = await downloadImageToLocal(imageUrl);
      await ImageGallerySaver.saveFile(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image saved to gallery!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to download image: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> shareImage(BuildContext context, String imageUrl) async {
    try {
      final filePath = await downloadImageToLocal(imageUrl);
      await Share.shareXFiles([XFile(filePath)],
          text: 'Check out this cool wallpaper!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to share image: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> setAsWallpaper(BuildContext context, String imageUrl) async {
    try {
      final filePath = await downloadImageToLocal(imageUrl);
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Set as Home Screen'),
                onTap: () async {
                  Navigator.pop(context);
                  await _setWallpaper(
                      context, filePath, WallpaperManagerFlutter.HOME_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Set as Lock Screen'),
                onTap: () async {
                  Navigator.pop(context);
                  await _setWallpaper(
                      context, filePath, WallpaperManagerFlutter.LOCK_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Set as Both'),
                onTap: () async {
                  Navigator.pop(context);
                  await _setWallpaper(
                      context, filePath, WallpaperManagerFlutter.BOTH_SCREENS);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper: $e')),
      );
    }
  }

  Future<void> _setWallpaper(
      BuildContext context, String filePath, int screen) async {
    try {
      await WallpaperManagerFlutter().setwallpaperfromFile(
        File(filePath),
        screen,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallpaper set successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'https://mrwallpaper.com/images/hd/mountains-peak-aesthetic-iphone-11-qb5wkq8a3zsubfxl.jpg',
      'https://images.pexels.com/photos/5007442/pexels-photo-5007442.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      'https://thepetiteplanner.com/wp-content/uploads/2024/01/hello-february-phone-background-24-2.png',
      'https://plus.unsplash.com/premium_photo-1686255006386-5f58b00ffe9d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dmVydGljYWwlMjB3YWxscGFwZXJ8ZW58MHx8MHx8fDA%3D',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1L0chF_VUdPShMo6b8WTTL1TLdC9Lx6G6PA&s',
      'https://images.unsplash.com/photo-1500817487388-039e623edc21?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvbmUlMjBiYWNrZ3JvdW5kfGVufDB8fDB8fHww',
      'https://i.pinimg.com/564x/61/25/59/6125595537c8fb5fc9c7e6cb256155e9.jpg',
      'https://e0.pxfuel.com/wallpapers/139/116/desktop-wallpaper-dark-sky-half-moon-lune-noire-phase-de-la-lune-lune-couple-half-thumbnail.jpg',
      'https://e1.pxfuel.com/desktop-wallpaper/848/173/desktop-wallpaper-100-black-moon-dark-moon-aesthetic-thumbnail.jpg',
      'https://images.unsplash.com/photo-1624280664758-4350adc906c1?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bmF0dXJlJTIwcGhvbmUlMjB3YWxscGFwZXJ8ZW58MHx8MHx8fDA%3D',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTS3maWCUo6Ql0M75F7pkbfHamX7VLmrSy23A&s',
      'https://corriebromfield.com/wp-content/uploads/2018/09/stars-hollow-2.jpg',
      'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvdjUzNWJhdGNoMi1teW50LTQzLmpwZw.jpg',
      'https://i.pinimg.com/564x/3e/38/fc/3e38fc12fddf4095aece24dc19471f47.jpg',
      'https://e1.pxfuel.com/desktop-wallpaper/840/147/desktop-wallpaper-aesthetic-pink-clouds-and-backgrounds-on-picgaga.jpg',
      'https://images.pexels.com/photos/3934623/pexels-photo-3934623.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      'https://images.unsplash.com/photo-1500817487388-039e623edc21?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvbmUlMjBiYWNrZ3JvdW5kfGVufDB8fDB8fHww',
      'https://i.pinimg.com/474x/27/d9/61/27d961b3718c7e364ce2efadaecdc0c6.jpg',
      'https://cdn.shopify.com/s/files/1/0504/2932/9574/files/molang_kiki_sorciere_mobile.jpg?v=1716456678'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trending',
          style:
              TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // leading: Icon(Icons.web_stories_sharp),
        backgroundColor: Colors.white,
      ),
      body: CarouselSlider.builder(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          viewportFraction: 1.0,
          scrollDirection: Axis.vertical,
        ),
        itemCount: images.length,
        itemBuilder: (context, index, _) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.5), // Semi-transparent black background
                    borderRadius: BorderRadius.circular(
                        8.0), // Round corners for the tile
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTileSection(
                        icon: Icons.download,
                        label: 'Download',
                        onPressed: () => downloadImage(context, images[index]),
                      ),
                      _buildTileSection(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () => shareImage(context, images[index]),
                      ),
                      _buildTileSection(
                        icon: Icons.wallpaper,
                        label: 'Set as Wallpaper',
                        onPressed: () => setAsWallpaper(context, images[index]),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: 300,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_double_arrow_up_outlined,
                        size: 36.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Swipe",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTileSection({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28.0, // Icon size
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
