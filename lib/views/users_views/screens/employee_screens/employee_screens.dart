import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../service/employee_service.dart';

class EmployeeScreens extends StatefulWidget {
  const EmployeeScreens({super.key});

  @override
  State<EmployeeScreens> createState() => _EmployeeScreensState();
}

class _EmployeeScreensState extends State<EmployeeScreens> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController =  TextEditingController();
  final TextEditingController _passController =  TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService(); // EmployeeService instance


  final CollectionReference _items =
  FirebaseFirestore.instance.collection('Employee');

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
                    'ຂໍ້ມູນພະນັກງານ', style: GoogleFonts.notoSansLao(
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
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'Id່', // Lao label text
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
                TextField(
                  controller: _passController,
                  decoration: InputDecoration(
                    labelText: 'Password', // Lao label text
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
                        final String id = _idController.text;
                        final String pass = _passController.text;


                        if (name.isNotEmpty) {
                          await _items.add({
                            "name": name,
                            "id":id,
                            "password":pass,
                            "dateOfBirth":'',
                            "departmentId":'',
                            "email":'',
                            "phone":'',
                            "positionId":'',
                            "profileImage":'',
                            "qualification":''

                          });
                          _nameController.text = '';
                          _idController.text = '';
                          _passController.text = '';

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
  Future<void> _update(String? employeeId) async {
    if (employeeId != null) {
      // Fetch the document or use stored values
      final snapshot = await FirebaseFirestore.instance.collection('Employee').doc(employeeId).get();
      _nameController.text = snapshot['name'];
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'ຂໍ້ມູນພະນັກງານ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ຊື່',
                  hintText: 'eg. Elon',
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
                    side: const BorderSide(color: Colors.red),
                  ),
                  backgroundColor: const Color.fromRGBO(214, 0, 27, 1),
                ),
                onPressed: () async {
                  final String name = _nameController.text;
                  if (name.isNotEmpty && employeeId != null) {
                    // Update the Firestore document
                    await FirebaseFirestore.instance
                        .collection('Employee')
                        .doc(employeeId)
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  // Future<void> _delete(String employeeId) async {
  //   await FirebaseFirestore.instance.collection('Employee').doc(employeeId).delete();
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("You have successfully deleted the employee")),
  //   );
  // }
  void _delete(String employeeId) async {
    try {
      await _employeeService.deleteEmployee(employeeId); // Delete employee by ID
      print('Employee deleted successfully');
    } catch (e) {
      print('Error deleting employee: $e');
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClicked = false;


  @override
  Widget build(BuildContext context) {
    final EmployeeService _employeeService = EmployeeService();
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
          'ຂໍ້ມູນພະນັກງານ',
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


      body: StreamBuilder<List<Employee>>(
        stream: _employeeService.searchEmployees(searchText),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: LoadingAnimationWidget.threeArchedCircle(
    color: Colors.white,
    size: 100,
    ),
    );
    }

    if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    }

    final List<Employee> employees = snapshot.data ?? [];

    if (employees.isEmpty) {
    return Center(child: Text('No items found.'));
    }

    return ListView.builder(
    itemCount: employees.length,
    itemBuilder: (context, index) {
      final Employee employee = employees[index];

      // Fetch department and position names
      return FutureBuilder<Department?>(
        future: _employeeService.getDepartment(employee.departmentId),
        builder: (context, departmentSnapshot) {
          if (departmentSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 100,
              ),
            );
          }

          if (departmentSnapshot.hasError) {
            return Text('Error: ${departmentSnapshot.error}');
          }

          final department = departmentSnapshot.data;

          return FutureBuilder<Position?>(
            future: _employeeService.getPosition(employee.positionId),
            builder: (context, positionSnapshot) {
              if (positionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 100,
                  ),
                );
              }

              if (positionSnapshot.hasError) {
                return Text('Error: ${positionSnapshot.error}');
              }

              final position = positionSnapshot.data;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      employee.profileImage.isEmpty
                          ? 'https://gratisography.com/wp-content/uploads/2023/10/gratisography-cool-cat-800x525.jpg'
                          : employee.profileImage,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ພາກວິຊາ: ${department?.name ?? 'ບໍ່ມີຂໍໍໍມູນ'}",style: GoogleFonts.notoSansLao(
                      fontSize: 15, ),),
                      Text("ຕໍາແໜ່ງ: ${position?.name ?? 'ບໍ່ມີຂໍໍໍມູນ'}",style: GoogleFonts.notoSansLao(
                        fontSize: 15, ),),
                      Text("ວດປ: ${employee.dateOfBirth}",style: GoogleFonts.notoSansLao(
                        fontSize: 15, ),),
                      Text("ID: ${employee.employeeId}",style: GoogleFonts.notoSansLao(
                        fontSize: 15, ),),
                      Text("Password: ${employee.password}",style: GoogleFonts.notoSansLao(
                        fontSize: 15, ),),

                      Text("ເບິໂທ: ${employee.phone}",style: GoogleFonts.notoSansLao(
                        fontSize: 15, ),),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          color: Colors.orangeAccent,
                          onPressed: () => _update(employee.id),
                          icon: const Icon(Icons.edit),
                        ),
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
                              _delete(employee.id); // Delete the employee document by ID
                            }
                          },
                          icon: const Icon(Icons.delete),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }  );
    }),




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