import 'package:admin_timesabai/views/users_views/screens/provinces_screens/report_provinces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class UserScreens extends StatefulWidget {
  const UserScreens({super.key});

  @override
  State<UserScreens> createState() => _UserScreensState();
}

class _UserScreensState extends State<UserScreens> {
  final List<Color> colors = [
    Color(0xFF5AD1fA),
    Color(0xFF836FF0),
    Color(0XFF1AC286),
    Color(0XFFF984BC),
    Color(0xFFBFBFA9),
    Color(0xFFBF2EF0),
    Color(0xFFB6FFA1),
    Color(0xFFB4E380),
  ];
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmpassController =
      new TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var options = [
    'ບໍລິຫານ',
    'ຄະນະບໍດີ',
  ];
  var _currentItemSelected = "ຄະນະບໍດີ";
  var rool = "ຄະນະບໍດີ";

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('Users');

  String searchText = '';
  void signUp(String email, String password, String rool) async {
    CircularProgressIndicator();

    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => {postDetailsToFirestore(email, rool)})
        .catchError((e) {});
  }

  postDetailsToFirestore(String email, String rool) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('Users');
    ref.doc(user!.uid).set({'email': emailController.text, 'rool': rool});
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ຈັດການຂໍ້ມູນຜູ້ໃຊ້ລະບົບ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'ອີເມວ',
                      hintText: 'eg.Elon',
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                      hintStyle: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'ລະຫັດຜ່ານ',
                      hintText: 'eg.Elon',
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                      hintStyle: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextField(
                    controller: confirmpassController,
                    decoration: InputDecoration(
                      labelText: 'ລະຫັດຜ່ານອີກຄັ້ງ',
                      hintText: 'eg.Elon',
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                      hintStyle: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'ສິດການເຂົ້າໃຊ້ລະບົບ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButton<String>(
                    elevation: 0,
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    focusColor: Colors.black,
                    items: options.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(
                          dropDownStringItem,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValueSelected) {
                      setModalState(() {
                        _currentItemSelected = newValueSelected!;
                        rool = newValueSelected;
                      });
                    },
                    value: _currentItemSelected,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          signUp(emailController.text, passwordController.text,
                              rool);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.blueAccent,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ບັນທຶກ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      emailController.text = documentSnapshot['name'];
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
                    'ຂໍ້ມຸນຜູ້ໃຊ້ລະບົບ',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                TextField(
                    controller: emailController,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 10,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.red),
                      ),
                      backgroundColor: Color.fromRGBO(214, 0, 27, 1)),
                  onPressed: () async {
                    // final String name = _nameController.text;
                    // if (name.isNotEmpty) {
                    //   await _items
                    //       .doc(documentSnapshot!.id)
                    //       .update({"name": name});
                    //   _nameController.text = '';
                    //   Navigator.of(context).pop();
                    // }
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
        });
  }

  // for delete operation
  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    // for snackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      "ລົບຂໍ້ມຸນຜູ້ໃຊ້ລະບົບສໍາເລັດ",
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
                          'ຈັດການຂໍ້ມຸນຜູ້ໃຊ້ລະບົບ',
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
                        final List<DocumentSnapshot> items =
                            streamSnapshot.data!.docs.toList();
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
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12))),
                                    height: 72,
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            documentSnapshot['email'],
                                            style: GoogleFonts.notoSansLao(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            documentSnapshot['rool'],
                                            style: GoogleFonts.notoSansLao(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                        ],
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
                      builder: (context) => ReportProvinces(docId: docId),
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
