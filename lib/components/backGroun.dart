import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BackGround extends StatefulWidget {
  final Widget child;

  BackGround({required this.child});

  @override
  _BackGroundState createState() => _BackGroundState();
}

class _BackGroundState extends State<BackGround> {
  String? imageUrl;
  List<String> imageUrlsList = [];
  Future<void> fetchImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('images')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<String> imageUrls = [];
        for (var doc in snapshot.docs) {
            imageUrls.add(doc['image_url']);
        }
        setState(() {
          imageUrlsList = imageUrls;
        });
      } else {
        print('No images found');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImages();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageUrlsList.isNotEmpty
              ? CachedNetworkImageProvider(imageUrlsList[0])
              : const CachedNetworkImageProvider(
            "https://www.iro-su.edu.la/wp-content/uploads/slider/cache/b103b63cc699a591fa912d8d463dba03/WhatsApp-Image-2023-12-13-at-15.00.23.jpg", // fallback image
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 100,
                right: 119,
                child: Image.asset(
                  'assets/icons/images.png',
                  width: 160,
                ),
              ),
              widget.child,
              if (imageUrlsList.isEmpty)
                 Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 100,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
