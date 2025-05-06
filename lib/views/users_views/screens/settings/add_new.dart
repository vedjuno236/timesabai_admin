import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/news_screens.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNew extends StatefulWidget {
  const AddNew({Key? key}) : super(key: key);

  @override
  _AddNewState createState() => _AddNewState();
}

class _AddNewState extends State<AddNew> {
  List<File> _mages = [];
  bool isLoading = false;
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage != null && returnImage.path.isNotEmpty) {
      setState(() {
        _mages.add(File(returnImage.path));
      });
    }
  }

  Future<void> _saveNews() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to save data')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<String> imageUrls = [];

      for (var file in _mages) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('news_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(file.path));

        print('Starting upload for file: $fileName');
        try {
          TaskSnapshot snapshot =
              await uploadTask.timeout(Duration(seconds: 20));
          print('Upload state for $fileName: ${snapshot.state}');
          if (snapshot.state == TaskState.success) {
            String downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          } else {
            throw Exception(
                'Failed to upload image: $fileName, state: ${snapshot.state}');
          }
        } catch (e) {
          print('Upload error for $fileName: $e');
          throw Exception('Failed to upload image: $fileName, error: $e');
        }
      }

      print('Saving to Firestore...');
      await FirebaseFirestore.instance.collection('news').add({
        'author': _authorController.text,
        'category': _typeController.text,
        'title': _contentController.text,
        'images': imageUrls,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': '',
        'videoUrl': '',
        'isFavorite': false,
        'likeCount': 0,
      });
      print('Firestore save completed');

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'ບັນທືກສໍາເລັດ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (mounted) {
        setState(() {
          _mages.clear();
          _authorController.clear();
          _typeController.clear();
          _contentController.clear();
          isLoading = false;
        });
        print('UI updated, isLoading = $isLoading');

        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsScreens()),
            // (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error saving data: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Error setState called, isLoading = $isLoading');
      }
    } finally {
      print('Finally block executed, setting isLoading to false');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Finally setState called, isLoading = $isLoading');
        setState(() {}); // บังคับ rebuild
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget, isLoading = $isLoading');
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'ເພີ່ມຂ່າວສານ',
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _mages.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'ແຕະເພື່ອເພີ່ມຮູບພາບ',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mages.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _mages[index],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _mages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black45,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'ຂະແໜ່ງການທີຂຽນຂ່າວ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _authorController,
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: "ຜູ້ຂຽນ",
                  hintStyle: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'ປະເພດຂ່າວສານ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _typeController,
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: "ປະເພດ",
                  hintStyle: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'ເນື້ອໃນ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                maxLines: 3,
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: "ເນື້ອໃນ",
                  hintStyle: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            if (_authorController.text.isEmpty ||
                _typeController.text.isEmpty ||
                _contentController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບຖ້ວນ')),
              );
              return;
            }
            _saveNews();
          },
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: isLoading
                ? Center(
                    child: Text(
                      'ກໍາລັງບັນທືກ .....',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'ບັນທືກ',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
