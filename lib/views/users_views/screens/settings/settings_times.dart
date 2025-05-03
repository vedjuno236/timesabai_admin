import 'dart:ffi';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_timesabai/views/users_views/screens/department_screens/report_department.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class Settings_Times extends StatefulWidget {
  const Settings_Times({super.key});

  @override
  State<Settings_Times> createState() => _Settings_TimesState();
}

class _Settings_TimesState extends State<Settings_Times> {
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
  FirebaseFirestore.instance.collection('times');
  DateTime selectedTime = DateTime.now();
  String searchText = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController timeController = TextEditingController();

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    mode: CupertinoDatePickerMode.time,
                    onDateTimeChanged: (date) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          date.hour,
                          date.minute,
                        );
                        timeController.text = DateFormat('HH:mm').format(selectedTime);

                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                      onPressed: () async {
                DateTime currentDate = DateTime.now();
                DateTime timeOnlyDateTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                selectedTime.hour,
                selectedTime.minute,
                0, 0, 0
                );
                await FirebaseFirestore.instance.collection('times').add({
                'times': Timestamp.fromDate(timeOnlyDateTime),
                });

                Navigator.of(context).pop();
                },


                  style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ບັນທືກ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _update({DocumentSnapshot? documentSnapshot}) async {
    if (documentSnapshot != null) {
      // Fetch the current 'times' field from the document and set the initial value for selectedDate
      Timestamp times = documentSnapshot['times'];
      selectedDate = times.toDate();
    }

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    mode: CupertinoDatePickerMode.time,
                    onDateTimeChanged: (date) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          date.hour,
                          date.minute,
                        );
                        timeController.text = DateFormat('HH:mm').format(selectedTime);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Ensure selectedTime is set correctly
                          DateTime currentDate = DateTime.now();
                          DateTime timeOnlyDateTime = DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                              0, 0, 0);

                          // Update the existing document with the new time
                          if (documentSnapshot != null) {
                            await FirebaseFirestore.instance
                                .collection('times')
                                .doc(documentSnapshot.id) // Use the document ID to reference the existing document
                                .update({
                              'times': Timestamp.fromDate(timeOnlyDateTime), // Update the 'times' field
                            });
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ແກ້ໄຂ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "'ຂໍ້ມູນເວລາເຂົ້າ - ອອກ",
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
                    'ຂໍ້ມູນເວລາເຂົ້າ - ອອກ',
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
                          final List<DocumentSnapshot> items = streamSnapshot.data!.docs;

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final times = item['times'];
                              String formatDate = '';  // Default empty string for formatDate

                              if (times != null && times is Timestamp) {
                                DateTime timesDateTime = times.toDate();
                                formatDate = DateFormat('HH:mm').format(timesDateTime); // Now it will be available
                              }

                              return Card(
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: colors[index % colors.length],
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12))),
                                      height: 95,
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ເວລາເຂົ້າ: $formatDate',  // Display the formatted time here
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
                    )

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
