import 'package:admin_timesabai/views/users_views/screens/branch_screens/report_branch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../../../models/department_model.dart';
import '../../../../service/department_service.dart';

class BranchScreens extends StatefulWidget {
  const BranchScreens({super.key});

  @override
  State<BranchScreens> createState() => _BranchScreensState();
}

class _BranchScreensState extends State<BranchScreens> {
  final List<Color> colors = [
    Color(0xFF5AD1fA),
    Color(0xFF836FF0),
    Color(0XFF1AC286),
    Color(0XFFF984BC)
  ];

  String? selectedDepartmentId;
  List<DepartmentModel> departments = [];
  bool isLoadingDepartments = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('Branch');

  String searchText = '';

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
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
                      'ຂໍ້ມູນາສາຂາ',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45),
                    ),
                  ),
                  Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoadingDepartments
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButton<String>(
                              value: selectedDepartmentId,
                              hint: Text(
                                'ເລືອກພາກວິຊາ',
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  selectedDepartmentId = newValue;
                                });
                              },
                              items:
                                  departments.map((DepartmentModel department) {
                                return DropdownMenuItem<String>(
                                  value: department.id,
                                  child: Text(
                                    department.name,
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              underline: const SizedBox(),
                            )),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'ຊື່', // Lao label text
                      hintText: 'eg. Elon', // Hint text
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
                          final String departmentId =
                              selectedDepartmentId ?? '';
                          if (name.isNotEmpty) {
                            await _items.add(
                                {"name": name, "departmentId": departmentId});
                            _nameController.text = '';
                            selectedDepartmentId = '';
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.blueAccent,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
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
        });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClicked = false;

  Future<void> fetchDepartments() async {
    try {
      departments = await ApiService().fetchDepartments();
      setState(() {
        isLoadingDepartments = false;
      });
    } catch (error) {
      debugPrint("Error fetching departments: $error");
      setState(() {
        isLoadingDepartments = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // for update operation
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      selectedDepartmentId =
          documentSnapshot['departmentId']; // Adjust field name if needed
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
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
                        'ຂໍ້ມູນາສາຂາ',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45),
                      ),
                    ),
                    Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoadingDepartments
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButton<String>(
                              value: selectedDepartmentId,
                              hint: Text(
                                'ເລືອກພາກວິຊາ',
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  selectedDepartmentId = newValue;
                                });
                              },
                              items:
                                  departments.map((DepartmentModel department) {
                                return DropdownMenuItem<String>(
                                  value: department.id,
                                  child: Text(
                                    department.name,
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              underline: const SizedBox(),
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.red),
                        ),
                        backgroundColor: Color.fromRGBO(214, 0, 27, 1),
                      ),
                      onPressed: () async {
                        final String name = _nameController.text;

                        if (name.isNotEmpty && selectedDepartmentId != null) {
                          await _items.doc(documentSnapshot!.id).update({
                            "name": name,
                            "departmentId":
                                selectedDepartmentId, // Add the departmentId field
                          });

                          _nameController.text = '';
                          Navigator.of(context).pop();
                        } else {
                          // You might show an error message if no department is selected or the name is empty
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Please enter a name and select a department')));
                        }
                      },
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
              );
            },
          );
        });
  }

  // for delete operation
  Future<void> _delete(String productID) async {
    await _items.doc(productID).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You have successfully deleted an Department")));
  }

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
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 0, 16, 0),
                                hintStyle: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                border: InputBorder.none,
                                hintText: 'ຄົ້ນຫາ..',
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
                          icon:
                              Icon(Icons.close, color: Colors.white, size: 30),
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
                          'ຂໍ້ມູນສາຂາ',
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
                  ).animate().scaleXY(
                    begin: 0,
                    end: 1,
                    delay: 500.ms,
                    duration: 500.ms,
                    curve: Curves.easeInOutCubic),
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _items.snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      }

                      if (streamSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${streamSnapshot.error}'));
                      }

                      if (!streamSnapshot.hasData ||
                          streamSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No items found.'));
                      }

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
                          String departmentId =
                              documentSnapshot['departmentId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Department')
                                .doc(departmentId)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot>
                                    departmentSnapshot) {
                              if (departmentSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child:
                                      LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white,
                                    size: 100,
                                  ),
                                );
                              }

                              if (departmentSnapshot.hasError) {
                                return Text(
                                    'Error: ${departmentSnapshot.error}');
                              }

                              if (departmentSnapshot.hasData &&
                                  departmentSnapshot.data != null) {
                                String departmentName =
                                    departmentSnapshot.data!['name'];

                                return Card(
                                  elevation: 0,
                                  color: Colors.grey.withOpacity(0.1),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                colors[index % colors.length],
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                bottomLeft:
                                                    Radius.circular(12))),
                                        height: 70,
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            "ສາຂາ : ${documentSnapshot['name']}",
                                            style: GoogleFonts.notoSansLao(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "ພາກວີຊາ : ${departmentName}",
                                            style: GoogleFonts.notoSansLao(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
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
                                                    FontAwesomeIcons
                                                        .penToSquare,
                                                    size: 20,
                                                  ),
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
                                                      confirmButtonText:
                                                          "ຕົກລົງ",
                                                      cancelButtonText:
                                                          "ຍົກເລີກ",
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
                                                          PanaraDialogType
                                                              .success,
                                                    );
                                                  },
                                                  icon: const FaIcon(
                                                    FontAwesomeIcons.trashCan,
                                                    size: 20,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().scaleXY(
                                    begin: 0,
                                    end: 1,
                                    delay: 500.ms,
                                    duration: 500.ms,
                                    curve: Curves.easeInOutCubic);
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          );
                        },
                      );
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
        animatedIconTheme: const IconThemeData(size: 22.0),
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
                        .collection('Branch')
                        .doc('branchid')
                        .get();
                final docId = snapshot.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportBranch(docId: docId),
                  ),
                );
              } catch (e) {
                print('Error fetching document: $e');
              }
            },
            backgroundColor: Colors.yellow,
          ),
          SpeedDialChild(
            child: Icon(Icons.add_circle_outline, color: Colors.white),
            labelWidget: Text(
              'ເພີ່ມຂໍ້ມູນ',
              style: GoogleFonts.notoSansLao(),
            ),
            onTap: _create,
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
