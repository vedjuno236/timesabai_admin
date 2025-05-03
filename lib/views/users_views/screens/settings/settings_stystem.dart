import 'dart:io';

import 'package:admin_timesabai/views/users_views/screens/settings/password_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/settings_location.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/settings_times.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'news_screens.dart';

class SettingsStystem extends StatefulWidget {
  const SettingsStystem({super.key});

  @override
  State<SettingsStystem> createState() => _SettingsStystemState();
}

class _SettingsStystemState extends State<SettingsStystem> {
  final CollectionReference _items =
      FirebaseFirestore.instance.collection('images');
  bool _loading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? firestoreImageUrl;
  List<String> firestoreImageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchFirestoreImages();
  }

  Future<void> fetchFirestoreImages() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('images').get();
    List<String> imageUrls = [];
    for (var doc in querySnapshot.docs) {
      imageUrls.add(doc['image_url']);
    }
    setState(() {
      firestoreImageUrls = imageUrls;
      firestoreImageUrl =
          firestoreImageUrls.isNotEmpty ? firestoreImageUrls[0] : null;
    });
  }

  Future<void> updateImage(String documentId) async {
    if (_imageFile == null) return;

    setState(() => _loading = true);

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(_imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String newDownloadURL = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('images')
          .doc(documentId)
          .update({
        'image_url': newDownloadURL,
        'uploaded_at': Timestamp.now(),
      });

      setState(() {
        firestoreImageUrl = newDownloadURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'ແກ້ໄຂສາໍເລັດ',
          style: GoogleFonts.notoSansLao(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update image: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<String?> getDocumentIdForImage(String imageUrl) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('images')
        .where('image_url', isEqualTo: imageUrl)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<void> getImage(String documentId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      updateImage(documentId);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF577DF4),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Ionicons.chevron_back_outline, color: Colors.white),
        ),
        title: Text(
          "ການຕັ້ງຄ່າ",
          style: GoogleFonts.notoSansLao(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "ຮູບພາບພື້ນຫລັງຂອງແອັບ *",
              style: GoogleFonts.notoSansLao(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF577DF4)),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : firestoreImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(firestoreImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    String? documentId =
                        await getDocumentIdForImage(firestoreImageUrl!);
                    if (documentId != null) {
                      getImage(documentId);
                    } else {
                      print('No document ID found for this image');
                    }
                  },
                  child: _loading
                      ? Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color: Colors.white,
                            size: 100,
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload,
                          color: Colors.blue,
                          size: 90,
                        ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Settings_View()));
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF577DF4),
                          ),
                          child: Icon(
                            Ionicons.map,
                            color: Colors.blue.shade100,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "ຈັດການຕໍາແໜ່ງຂອງແອັບ",
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Ionicons.chevron_forward_outline),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Settings_Times()));
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          child: const Icon(
                            Ionicons.timer,
                            color: Colors.blue,
                            size: 49,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "ຈັດການເວລາການເຂົ້າວຽກ",
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Ionicons.chevron_forward_outline),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const NewsScreens()));
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          child: const Icon(
                            Ionicons.newspaper,
                            color: Color(0xFF577DF4),
                            size: 49,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "ຈັດການຂໍ້ມູນຂ່າວສານ",
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Ionicons.chevron_forward_outline),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PasswordScreens()));
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          child: const Icon(
                            Ionicons.cog_outline,
                            color: Color(0xFF577DF4),
                            size: 49,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "ປ່ຽນລະຫັດຜ່ານ",
                          style: GoogleFonts.notoSansLao(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Ionicons.chevron_forward_outline),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
