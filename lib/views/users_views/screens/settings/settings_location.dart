import 'dart:ffi';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_timesabai/views/users_views/screens/department_screens/report_department.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class Settings_View extends StatefulWidget {
  const Settings_View({super.key});

  @override
  State<Settings_View> createState() => _Settings_ViewState();
}

class _Settings_ViewState extends State<Settings_View> {
  final List<Color> colors = [
    Color(0xFF5AD1fA),
    Color(0xFF836FF0),
    Color(0XFF1AC286),
    Color(0XFFF984BC)
  ];

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _allowedDistance = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _items =
  FirebaseFirestore.instance.collection('settings');

  String searchText = '';

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'ຂໍ້ມູນຕໍາແໜ່ງ Google Map',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45),
                  ),
                ),
                TextField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: 'ລວງກ້ວາງ', // Lao label text
                    hintText: 'eg. 18.1234', // Hint text
                    labelStyle: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: 'ລວງຍາວ', // Lao label text
                    hintText: 'eg. 102.1234', // Hint text
                    labelStyle: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _allowedDistance,
                  decoration: InputDecoration(
                    labelText: 'ໄລຍະການບັນທືກໄດ້', // Lao label text
                    hintText: 'eg. 102.1234', // Hint text
                    labelStyle: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final double? latitude = double.tryParse(_latitudeController.text);
                        final double? longitude = double.tryParse(_longitudeController.text);
                        final double? allowedDistance = double.tryParse(_allowedDistance.text);

                        if (latitude != null && longitude != null && allowedDistance != null) {

                          await _items.add({
                            "targetLatitude": latitude,
                            "targetLongitude": longitude,
                            "allowedDistance": allowedDistance,
                          });
                          _latitudeController.clear();
                          _longitudeController.clear();
                          _allowedDistance.clear();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please enter valid numeric values.")),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'ບັນທືກ',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }


  Future<void> _update({DocumentSnapshot? documentSnapshot}) async {
    if (documentSnapshot != null) {
      // Populate the controllers with existing values from the document
      _latitudeController.text = documentSnapshot['targetLatitude'].toString();
      _longitudeController.text = documentSnapshot['targetLongitude'].toString();
      _allowedDistance.text = documentSnapshot['allowedDistance'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'ຂໍ້ມູນຕໍາແໜ່ງ  Google Map',
                  style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              TextField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: 'ລວງກ້ວາງ',
                  hintText: 'eg. 18.1234',
                  labelStyle: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: 'ລວງຍາວ',
                  hintText: 'eg. 102.1234',
                  labelStyle: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _allowedDistance,
                decoration: InputDecoration(
                  labelText: 'ໄລຍະການບັນທືກໄດ້',
                  hintText: 'eg. 102.1234',
                  labelStyle: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    backgroundColor: Color.fromRGBO(214, 0, 27, 1)),
                onPressed: () async {
                  final String latitude = _latitudeController.text;
                  final String longitude = _longitudeController.text;
                  final String allowedDistance = _allowedDistance.text;

                  // Check if the fields are not empty
                  if (latitude.isNotEmpty && longitude.isNotEmpty && allowedDistance.isNotEmpty) {
                    // Update the document with new values
                    await _items.doc(documentSnapshot!.id).update({
                      "targetLatitude": double.tryParse(latitude),
                      "targetLongitude": double.tryParse(longitude),
                      "allowedDistance": double.tryParse(allowedDistance),
                    });

                    // Clear the text controllers
                    _latitudeController.clear();
                    _longitudeController.clear();
                    _allowedDistance.clear();

                    // Close the bottom sheet
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'ແກ້ໄຂ',
                  style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // for delete operation
  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    // for snackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "ລົບຂໍ້ມູນຕໍາແໜ່ງ  Google Map",
          style: GoogleFonts.notoSansLao(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        )));
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClicked = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF577DF4),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF577DF4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isSearchClicked
                ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          contentPadding:
                          EdgeInsets.fromLTRB(16, 0, 16, 0),
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          hintText: 'Search..',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearchClicked = !isSearchClicked;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ຂໍ້ມູນຕໍາແໜ່ງ  Google Map',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearchClicked = !isSearchClicked;
                      });
                    },
                    icon:
                    Icon(Icons.search, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                    stream: _items.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        // Get the list of items directly without any filtering based on searchText
                        final List<DocumentSnapshot> items = streamSnapshot.data!.docs;

                        // Use the 'items' as it is, without filtering
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final latitude = item['targetLatitude'];
                            final longitude = item['targetLongitude'];
                            final allowedDistance = item['allowedDistance'];

                            return Card(
                              color: Colors.white,

                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(

                                        color: colors[index % colors.length],
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12))

                                    ),
                                    height: 95,
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title:
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [
                                            Text('ລວງກ້ວາງ:$latitude',
                                            style: GoogleFonts.notoSansLao(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black), ),
                                            Text(
                                              "ລວງຍາວ:${longitude}",
                                              style: GoogleFonts.notoSansLao(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "ໄລຍະການບັນທືກໄດ້:${allowedDistance}",
                                              style: GoogleFonts.notoSansLao(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),


                                      trailing: SizedBox(
                                        width: 100,
                                        child: Row(
                                          children: [

                                            IconButton(
                                              color: Colors.orangeAccent,
                                              onPressed: () {
                                                _update(documentSnapshot: item); // Correct named parameter usage
                                              },
                                              icon: const FaIcon(FontAwesomeIcons.penToSquare),
                                            ),


                                            IconButton(
                                              color: Colors.redAccent,
                                              onPressed: () async {

                                                PanaraConfirmDialog.showAnimatedGrow(
                                                  context,
                                                  color: Colors.blue,
                                                  title: "!!!!...!!!!",
                                                  message: "ທ່ານຕ້ອງການລົບແທ້ບໍ່.",
                                                  confirmButtonText: "ຕົກລົງ",
                                                  cancelButtonText: "ຍົກເລີກ",
                                                  onTapCancel: () {
                                                    Navigator.pop(context);
                                                  },
                                                  onTapConfirm: () {

                                                    _delete(item.id);
                                                    Navigator.pop(context);

                                                  },
                                                  panaraDialogType: PanaraDialogType.success,
                                                );
                                              },
                                              icon: const FaIcon(FontAwesomeIcons.trashCan),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        animatedIconTheme: IconThemeData(size: 22.0),
        curve: Curves.bounceIn,
        overlayColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 15.0,
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF577DF4),
        children: [
       
          SpeedDialChild(
              child: Icon(Icons.add_circle_outline, color: Colors.white),
              labelWidget: Text(
                'ເພີ່ມຂໍ້ມູນ',
                style: GoogleFonts.notoSansLao(),
              ),
              onTap: _create,
              backgroundColor: Color(0xFF577DF4)),
        ],
      ),
    );
  }
}
