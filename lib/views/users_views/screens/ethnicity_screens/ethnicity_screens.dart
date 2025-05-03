import 'package:admin_timesabai/views/users_views/screens/ethnicity_screens/report_ethnicity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class EthnicityScreens extends StatefulWidget {
  const EthnicityScreens({super.key});

  @override
  State<EthnicityScreens> createState() => _EthnicityScreensState();
}

class _EthnicityScreensState extends State<EthnicityScreens> {
  final List<Color> colors = [
    Color(0xFF5AD1fA),
    Color(0xFF836FF0),
    Color(0XFF1AC286),
    Color(0XFFF984BC)
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('Ethnicity');

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
                    'ຂໍ້ມູນຊົນເຜົ່າ',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'ຊື່', // Lao label text
                    hintText: 'eg.Elon', // Hint text
                    labelStyle: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                    hintStyle: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      color: Colors.grey, // Adjust the hint style as needed
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final String name = _nameController.text;
                        if (name.isNotEmpty) {
                          await _items.add({"name": name});
                          _nameController.text = '';
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // Button background color
                        foregroundColor: Colors.white,
                        // Text color
                        shadowColor: Colors.blueAccent,
                        // Shadow color
                        elevation: 5,
                        // Elevation (shadow depth)
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
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
                )
              ],
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 10,
                left: 10,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'ຂໍ້ມູນຊົນເຜົ່າ',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'ຊື່', // Lao label text
                      hintText: 'eg.Elon', // Hint text
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'ຍົກເລີກ',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                    ),
                    SizedBox(width: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.red),
                          ),
                          backgroundColor: Color.fromRGBO(214, 0, 27, 1)),
                      onPressed: () async {
                        final String name = _nameController.text;
                        if (name.isNotEmpty) {
                          await _items
                              .doc(documentSnapshot!.id)
                              .update({"name": name});
                          _nameController.text = '';
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
              ],
            ),
          );
        });
  }

  // for delete operation
  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    // for snackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      "ລົບຂໍ້ມູນຊົນເຜົ່າສໍາເລັດ",
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
                          'ຂໍ້ມູນຊົນເຜົ່າ',
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
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        final List<DocumentSnapshot> items = streamSnapshot
                            .data!.docs
                            .where((doc) => doc['name']
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                            .toList();
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                items[index];
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
                                    height: 72,
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        documentSnapshot['name'],
                                        style: GoogleFonts.notoSansLao(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      ),
                                      trailing: SizedBox(
                                        width: 100,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              color: Colors.orangeAccent,
                                              onPressed: () =>
                                                  _update(documentSnapshot),
                                              icon: const FaIcon(
                                                  FontAwesomeIcons.penToSquare),
                                            ),
                                            IconButton(
                                              color: Colors.redAccent,
                                              onPressed: () async {
                                                PanaraConfirmDialog
                                                    .showAnimatedGrow(
                                                  context,
                                                  color: Colors.blue,
                                                  title: "!!!!...!!!!",
                                                  message:
                                                      "ທ່ານຕ້ອງການລົບແທ້ບໍ່.",
                                                  confirmButtonText: "ຕົກລົງ",
                                                  cancelButtonText: "ຍົກເລີກ",
                                                  onTapCancel: () {
                                                    Navigator.pop(context);
                                                  },
                                                  onTapConfirm: () {
                                                    _delete(documentSnapshot
                                                        .id); // Call the delete method directly
                                                    Navigator.pop(
                                                        context); // Ensure to close the dialog after confirmation
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.success,
                                                );
                                              },
                                              icon: const FaIcon(
                                                  FontAwesomeIcons.trashCan),
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
              child: Icon(Icons.read_more, color: Colors.white),
              labelWidget: Text(
                'ລາຍງານຂໍ້ມູນ',
                style: GoogleFonts.notoSansLao(),
              ),
              onTap: () async {
                try {
                  final DocumentSnapshot<Map<String, dynamic>> snapshot =
                      await FirebaseFirestore.instance
                          .collection('Position')
                          .doc('positionid')
                          .get();
                  final docId = snapshot.id;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportEthnicty(docId: docId),
                    ),
                  );
                } catch (e) {
                  print('Error fetching document: $e');
                }
              },
              backgroundColor: Colors.yellow),
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
