import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

class UsersOrdersScreen extends StatefulWidget {
  @override
  _UsersOrdersScreenState createState() => _UsersOrdersScreenState();
}

class _UsersOrdersScreenState extends State<UsersOrdersScreen> {
  String _searchQuery = '';
  bool isSearchClicked = false;
  DateTime _selectedDate = DateTime.now();  // To track the selected date
  String _month = DateFormat('MMMM').format(DateTime.now());

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
                    onTap: () async {
                      final selectedDate =
                      await SimpleMonthYearPicker.showMonthYearPickerDialog(
                        context: context,
                        titleTextStyle: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1230AE),
                          ),
                        ),
                        monthTextStyle: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1230AE),
                          ),
                        ),
                        yearTextStyle: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1230AE),
                          ),
                        ),
                        disableFuture: true,
                      );

                      if (selectedDate != null) {
                        setState(() {
                          _selectedDate = selectedDate;  // Update the selected date
                          _month = DateFormat('MMMM').format(selectedDate);
                        });
                      }
                    },
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
                            "ເລືອກເດືອນ: ${_month.isEmpty ? "ເລືອກເດືອນ":_month}",
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
                                  .collection('Record')
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

                                // Filter orders by selected month
                                final filteredOrders = orders.where((order) {
                                  final date = (order['date'] as Timestamp).toDate();
                                  return date.month == _selectedDate.month &&
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
                                                    'ເວລາເຂົ້າ: ${record['checkIn']}',
                                                    style: GoogleFonts
                                                        .notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'ເວລາອອກ: ${record['checkOut']}',
                                                    style: GoogleFonts
                                                        .notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  TextButton(
                                                    onPressed: () {
                                                      print('Button pressed');
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
  Color getStatusColor(String status) {
    switch (status) {
      case 'ມາວຽກຊ້າ':
        return Colors.orange;
      case 'ຂາດວຽກ':
        return Colors.red;
      case 'ວັນພັກ':
        return Colors.black12;
      default:
        return Colors.blue;
    }
  }
}
