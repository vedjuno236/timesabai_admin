import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentScreens extends StatefulWidget {
  const DepartmentScreens({super.key});

  @override
  State<DepartmentScreens> createState() => _DepartmentScreensState();
}

class _DepartmentScreensState extends State<DepartmentScreens> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('Department');

  String searchText = '';

  // for create operation
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
                   'ຂໍ້ມູນພາກວິຊາ', style: GoogleFonts.notoSansLao(
                        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black45),),
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
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Text color
                        shadowColor: Colors.blueAccent, // Shadow color
                        elevation: 5, // Elevation (shadow depth)
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                        child:Text(
                          'ບັນທືກ', style: GoogleFonts.notoSansLao(
                            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  // for update operation
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
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child:Text(
                    'ຂໍ້ມູນພາກວີຊາ',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration:  InputDecoration(
          labelText: 'ຊື່', // Lao label text
          hintText: 'eg.Elon', // Hint text
          labelStyle: GoogleFonts.notoSansLao(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
          ),
                  )
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 10,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.red),
                      ),
                      backgroundColor: Color.fromRGBO(214, 0, 27, 1)
                  ),
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
                  child:Text(
                    'ແກ້ໄຂ', style: GoogleFonts.notoSansLao(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),),
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have successfully deleted an Department")));
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
        backgroundColor: Color(0xFFF193940),
        title: isSearchClicked
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      hintText: 'Search..'),
                ),
              )
            : Text(
                'ຂໍ້ມູນພາກວີຊາ',
                style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSearchClicked = !isSearchClicked;
                });
              },
              icon: Icon(isSearchClicked ? Icons.close : Icons.search))
        ],
      ),
      body: StreamBuilder(
        stream: _items.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items = streamSnapshot.data!.docs
                .where((doc) => doc['name'].toLowerCase().contains(
                      searchText.toLowerCase(),
                    ))
                .toList();
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.all(10),
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
                                onPressed: () => _update(documentSnapshot),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                              color: Colors.redAccent,
                              onPressed: () async {
                                final result = await showOkCancelAlertDialog(
                                  context: context,
                                  message: 'ທ່ານຕ້ອງການລົບແທ້ບໍ່',
                                  okLabel: 'ຕົກລົງ',
                                  cancelLabel: 'ຍົກເລີກ',

                                );

                                if (result == OkCancelResult.ok) {
                                  _delete(documentSnapshot.id); // Perform delete action
                                }
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        backgroundColor: const Color.fromARGB(255, 88, 136, 190),
        children: [
          SpeedDialChild(
              child: Icon(Icons.read_more, color: Colors.white),

              labelWidget: Text(
                'ລາຍງານຂໍ້ມູນ',
                style: GoogleFonts.notoSansLao(), // Applying Google Font to the label
              ),
              onTap: () => {},
              backgroundColor: Colors.yellow
          ),
          SpeedDialChild(
              child: Icon(Icons.add_circle_outline, color: Colors.white),
              labelWidget: Text(
                'ເພີ່ມຂໍ້ມູນ',
                style: GoogleFonts.notoSansLao(), // Applying Google Font to the label
              ),
              onTap: () => _create(),
              backgroundColor: Colors.blue
          ),
        ],
      ),
    );
  }
}
