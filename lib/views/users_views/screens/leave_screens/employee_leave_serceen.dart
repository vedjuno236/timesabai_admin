import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EmployeeLeaveSerceen extends StatefulWidget {
  const EmployeeLeaveSerceen({super.key});

  @override
  State<EmployeeLeaveSerceen> createState() => _EmployeeLeaveSerceenState();
}

class _EmployeeLeaveSerceenState extends State<EmployeeLeaveSerceen> {
  String _searchQuery = '';
  bool isSearchClicked = false;
  DateTime _selectedDate = DateTime.now();  // To track the selected date
  String _month = DateFormat('dd MMMM yyyy').format(DateTime.now());
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),


    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update selected date
        _month = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

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
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase(); // Update the search query
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              hintStyle: TextStyle(color: Colors.black),
              border: InputBorder.none,
              hintText: 'Search...',
            ),
          ),
        )
            : Text(
          'ຂໍ້ມູນມາປະຈໍາການ',
          style: GoogleFonts.notoSansLao(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClicked = !isSearchClicked;
              });
            },
            icon: Icon(isSearchClicked ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(

                      onTap: () => _selectDate(context),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(0xFFF193940),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.white),
                          Text(
                            "ເລືອກວັນທີ: ${_month.isEmpty ? "ເລືອກວັນທີ":_month}",
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFF193940),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.read_more, color: Colors.white),
                      Text(
                        "ລາຍງານຂໍ້ມູນ",
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Employee')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;

                      return Card(
                        color: Colors.white,
                        child: ExpansionTile(
                          title: Text(
                            user['name'],
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Employee')
                                  .doc(userId)
                                  .collection('Leave')
                                  .snapshots(),
                              builder: (context, orderSnapshot) {
                                if (orderSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                } else if (orderSnapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                            'Error: ${orderSnapshot.error}')),
                                  );
                                } else if (!orderSnapshot.hasData ||
                                    orderSnapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text('No orders found.')),
                                  );
                                }

                                final orders = orderSnapshot.data!.docs;

                                final filteredOrders = orders.where((order) {
                                  final date = (order['date'] as Timestamp).toDate();
                                  return date.month == _selectedDate.month &&
                                      date.day == _selectedDate.day &&
                                      date.year == _selectedDate.year;
                                }).toList();

                                final searchFilteredOrders = filteredOrders.where((order) {
                                  final status = order['status']
                                      .toString()
                                      .toLowerCase();
                                  return status.contains(_searchQuery);
                                }).toList();

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount: searchFilteredOrders.length,
                                      itemBuilder: (context, orderIndex) {
                                        final record =
                                        searchFilteredOrders[orderIndex]
                                            .data() as Map<String, dynamic>;

                                        return ExpansionTile(
                                          title: Text(
                                            "ວັນທີ: ${DateFormat.yMMMMEEEEd().format((record['date'] as Timestamp).toDate())}",
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                  20.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ຈາກວັນທີ: ${DateFormat.yMMMMEEEEd().format((record['fromDate'] as Timestamp).toDate())}',
                                                    style: GoogleFonts
                                                        .notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'ວັນທີສີ້ນສຸດ: ${DateFormat.yMMMMEEEEd().format((record['toDate'] as Timestamp).toDate())}',
                                                    style: GoogleFonts
                                                        .notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '${record['daySummary']}',
                                                    style: GoogleFonts.notoSansLao(fontSize: 15),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'ເຫດຜົນ: ${record['doc']}',
                                                    style: GoogleFonts.notoSansLao(fontSize: 15),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'ປະເພດລາພັກ: ${record['leaveType']}',
                                                    style: GoogleFonts.notoSansLao(fontSize: 15),
                                                  ),
                                                  SizedBox(height: 5),
                                                  TextButton(
                                                    onPressed: () {
                                                      _showEditStatusDialog(record['status'], userId, searchFilteredOrders[orderIndex].id);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: getStatusColor(record['status']),
                                                      foregroundColor: Colors.white,
                                                    ),

                                                    child: Text(
                                                      'ສະຖານະ: ${record['status']}',
                                                      style: GoogleFonts.notoSansLao(
                                                          fontSize: 15,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FullScreenImage(imageUrl: record['imageUrl']),
                                                        ),
                                                      );
                                                    },
                                                    child: Image.network(
                                                      record['imageUrl'],
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          return child;
                                                        }
                                                        return Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                                : null,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                        return const Text('Failed to load image');
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],


                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStatusDialog(String currentStatus, String userId, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = currentStatus; // Holds the status selected by the user

        return AlertDialog(
          title: Text(
            'ແກ້ໄຂສະຖານະ',
            style: GoogleFonts.notoSansLao(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });

                  // Show a message (using Snackbar in this case)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ເຈົ້າເລືອກ: $newValue',
                        style: GoogleFonts.notoSansLao(fontSize: 15),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                items: ['ອະນຸມັດແລ້ວ', 'ລໍຖ້າອະນຸມັດ', 'ປະຕິເສດ']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('ຍົກເລີກ', style: GoogleFonts.notoSansLao(fontSize: 15)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ບັນທຶກ', style: GoogleFonts.notoSansLao(fontSize: 15)),
              onPressed: ()  async {
                await FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(userId)
                    .collection('Leave')
                    .doc(messageId)
                    .update({'status': selectedStatus});


                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }





  Color getStatusColor(String status) {
    switch (status) {
      case 'ອະນຸມັດແລ້ວ':
        return Colors.blue;
      case 'ປະຕິເສດ':
        return Colors.red;
      default:
        return Colors.orangeAccent;
    }
  }
}



class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ຮູບພາບ',
          style: GoogleFonts.notoSansLao(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return const Text('Failed to load image', style: TextStyle(color: Colors.white));
          },
        ),
      ),
    );
  }



}



