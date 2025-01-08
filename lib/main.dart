import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wallpaper_app/trending.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StaticWallpaperApp());
}

class StaticWallpaperApp extends StatelessWidget {
  const StaticWallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WallpaperScreen(),
    );
  }
}

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  final List<String> imageUrls = [
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

  Future<String> downloadImageToLocal(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/wallpaper.jpg';
    final dio = Dio();
    await dio.download(imageUrl, filePath);
    return filePath;
  }

  Future<void> downloadImage(BuildContext context, String imageUrl) async {
    try {
      final filePath = await downloadImageToLocal(imageUrl);
      await ImageGallerySaver.saveFile(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: $e')),
      );
    }
  }

  Future<void> setAsWallpaper(String imageUrl) async {
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
                  Navigator.pop(context); // Close the modal
                  await _setWallpaper(
                      filePath, WallpaperManagerFlutter.HOME_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Set as Lock Screen'),
                onTap: () async {
                  Navigator.pop(context); // Close the modal
                  await _setWallpaper(
                      filePath, WallpaperManagerFlutter.LOCK_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Set as Both'),
                onTap: () async {
                  Navigator.pop(context); // Close the modal
                  await _setWallpaper(
                      filePath, WallpaperManagerFlutter.BOTH_SCREENS);
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

  Future<void> _setWallpaper(String filePath, int screen) async {
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

  Future<void> shareImage(String imageUrl) async {
    try {
      final filePath = await downloadImageToLocal(imageUrl);
      await Share.shareXFiles([XFile(filePath)],
          text: 'Check out this cool wallpaper!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '  Wallpaper Grid',
            style: TextStyle(
                color: Colors.orange[800], fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: Icon(Icons.web_stories_sharp),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrendingScreen()),
                );
              },
              icon: Icon(Icons.trending_up_rounded),
              tooltip: 'Trending',
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          color: Colors.white,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 5.0,
                childAspectRatio: 2 / 3),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return GestureDetector(
                onTap: () => _openImageViewer(context, imageUrl),
                // child: SizedBox(
                //   height: 600,
                //   child: Image.network(
                //     imageUrl,
                //     fit: BoxFit.fitWidth,
                //     width: double.infinity,
                //   ),
                // ),
                child: ShimmerLoadingImage(imageUrl: imageUrl),
              );
            },
          ),
        ));
  }

  void _openImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title:  Text('Zoomed view' , style: TextStyle(color: Colors.orange[800] , fontWeight: FontWeight.bold),),
            backgroundColor: Colors.white,
            centerTitle: true,
            // leading: Icon(Icons.web_stories_sharp),
          ),
          body: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained,
              ),
              Positioned(
                bottom: 5,
                left: 20,
                right: 20,
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTileSection(
                        icon: Icons.download,
                        label: 'Download',
                        onPressed: () => downloadImage(context, imageUrl),
                      ),
                      _buildTileSection(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () => shareImage(imageUrl),
                      ),
                      _buildTileSection(
                        icon: Icons.wallpaper,
                        label: 'Set as Wallpaper',
                        onPressed: () => setAsWallpaper(imageUrl),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

class ShimmerLoadingImage extends StatelessWidget {
  final String imageUrl;

  ShimmerLoadingImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey,
              height: 600,
              width: double.infinity,
            ),
          ),
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 600,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
// final String imageUrl =
  //     'https://w0.peakpx.com/wallpaper/67/686/HD-wallpaper-black-and-white-boring-outline-simple.jpg';

  
  // Future<String> downloadImageToLocal() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final filePath = '${directory.path}/wallpaper.jpg';
  //   final dio = Dio();
  //   await dio.download(imageUrl, filePath);
  //   return filePath;
  // }

  // Future<void> downloadImage(BuildContext context) async {
  //   try {
  //     final filePath = await downloadImageToLocal();
  //     final result = await ImageGallerySaver.saveFile(filePath);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Image saved to gallery !')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to download image: $e')),
  //     );
  //   }
  // }

  // Future<void> setAsWallpaper() async {
  //   try {
  //     final filePath = await downloadImageToLocal();

  //     // Show options to the user
  //     showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: Icon(Icons.home),
  //               title: Text('Set as Home Screen'),
  //               onTap: () async {
  //                 Navigator.pop(context); // Close the modal
  //                 await _setWallpaper(
  //                     filePath, WallpaperManagerFlutter.HOME_SCREEN);
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.lock),
  //               title: Text('Set as Lock Screen'),
  //               onTap: () async {
  //                 Navigator.pop(context); // Close the modal
  //                 await _setWallpaper(
  //                     filePath, WallpaperManagerFlutter.LOCK_SCREEN);
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.phone_android),
  //               title: Text('Set as Both'),
  //               onTap: () async {
  //                 Navigator.pop(context); // Close the modal
  //                 await _setWallpaper(
  //                     filePath, WallpaperManagerFlutter.BOTH_SCREENS);
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to set wallpaper: $e')),
  //     );
  //   }
  // }

  // Future<void> _setWallpaper(String filePath, int screen) async {
  //   try {
  //     await WallpaperManagerFlutter().setwallpaperfromFile(
  //       File(filePath),
  //       screen,
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Wallpaper set successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to set wallpaper: $e')),
  //     );
  //   }
  // }

  // Future<void> shareImage() async {
  //   try {
  //     final filePath = await downloadImageToLocal();
  //     await Share.shareXFiles([XFile(filePath)],
  //         text: 'Check out this cool wallpaper!');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to share image: $e')),
  //     );
  //   }
  // }

  
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Static Wallpaper App'),
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //             child: SingleChildScrollView(
  //           child: Center(
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Image.network(
  //                 imageUrl,
  //                 fit: BoxFit.cover,
  //                 height: 270,
  //                 width: 200,
  //               ),
  //             ),
  //           ),
  //         )),
  //         Container(
  //           color: Colors.white,
  //           padding:
  //               const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               ElevatedButton.icon(
  //                 icon: Icon(Icons.download),
  //                 label: Text('Download'),
  //                 onPressed: () => downloadImage(context),
  //               ),
  //               ElevatedButton.icon(
  //                 icon: Icon(Icons.wallpaper),
  //                 label: Text('Wallpaper'),
  //                 onPressed: setAsWallpaper,
  //               ),
  //               ElevatedButton.icon(
  //                 icon: Icon(Icons.share),
  //                 label: Text('Share'),
  //                 onPressed: shareImage,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }