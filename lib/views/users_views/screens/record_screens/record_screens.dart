import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

import '../../../../service/record_service.dart';

class RecordScreens extends StatefulWidget {
  const RecordScreens({super.key});

  @override
  State<RecordScreens> createState() => _RecordScreensState();
}

class _RecordScreensState extends State<RecordScreens> {
  final TextEditingController _searchController = TextEditingController();
  final RecordService _firestoreService = RecordService();
  List<DocumentSnapshot>? users;
  String searchText = '';
  bool isSearchClicked = false;


  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }



  Future<void> _fetchUsers() async {
    if (searchText.isEmpty) {
      users = await _firestoreService.getUsers();
    } else {
      users = [];
      List<DocumentSnapshot> allUsers = await _firestoreService.getUsers();

      for (var user in allUsers) {
        List<DocumentSnapshot> subCollectionResults =
        await _firestoreService.searchRecordsInSubCollection(user.id, searchText);

        if (subCollectionResults.isNotEmpty) {
          bool hasMatchingStatus = subCollectionResults.any((record) {
            var recordData = record.data() as Map<String, dynamic>;
            return recordData['status']?.toString().contains(searchText) ?? false;
          });

          if (hasMatchingStatus) {
            users?.add(user);
          }
        }
      }
    }
    setState(() {});
  }


  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              hintStyle: TextStyle(color: Colors.black),
              border: InputBorder.none,
              hintText: 'Search..',
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
        iconTheme: IconThemeData(color: Colors.white),
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
      body: users == null
          ? const Center(child: CircularProgressIndicator())
          : buildUsersWithMessages(),

    );
  }

  Widget buildUsersWithMessages() {
    String _month = DateFormat('MMMM').format(DateTime.now());

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () async {
                  final selectedDate = await SimpleMonthYearPicker
                      .showMonthYearPickerDialog(
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

                  final DateFormat laoDateFormat = DateFormat.MMMM(
                      'lo');
                  String formattedDate = laoDateFormat.format(selectedDate);

                  print('Selected Date in Lao: $formattedDate');

                  setState(() {
                    _month =
                        formattedDate;
                  });
                                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:  Color(0xFFF193940),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month,color: Colors.white,),
                      Text(
                        "ເລືອກເດືອນ",
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
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:  Color(0xFFF193940),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(Icons.read_more,color: Colors.white,),
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
          child: ListView.builder(
            itemCount: users!.length,
            itemBuilder: (context, index) {
              var userData = users![index].data() as Map<String, dynamic>;
              String userId = users![index].id; // Get user ID

              return ExpansionTile(
                title: Text(
                  "ຊື່ : ${userData['name'] ?? 'Unnamed User'}",
                  style: GoogleFonts.notoSansLao(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:  Color(0xFFF193940),
                  ),
                ),
                children: [
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _firestoreService.getUserMessages(userId),
                    builder: (context, messagesSnapshot) {
                      if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                        return  ListTile(title: Text('ກໍາລັງໂຫລດຂໍ້ມູນ!.',style: GoogleFonts.notoSansLao(fontSize: 15),));
                      }
                      if (messagesSnapshot.hasError) {
                        return ListTile(title: Text('Error: ${messagesSnapshot.error}'));
                      }

                      final messages = messagesSnapshot.data;

                      if (messages == null || messages.isEmpty) {
                        return  ListTile(title: Text('ບໍມີຂໍ້ມູນ!.',style: GoogleFonts.notoSansLao(fontSize: 15),));
                      }

                      return Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: messages.length,
                            itemBuilder: (context, messageIndex) {
                              var messageData = messages[messageIndex].data() as Map<String, dynamic>;

                              return ExpansionTile(
                                title: Text(
                                  'ວັນທີ: ${DateFormat.yMMMMEEEEd().format((messageData['date'] as Timestamp).toDate())}',

                                  style: GoogleFonts.notoSansLao(
                                    fontSize: 15,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ເວລາເຂົ້າ: ${messageData['checkIn']}',
                                          style: GoogleFonts.notoSansLao(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'ເວລາອອກ: ${messageData['checkOut']}',
                                          style: GoogleFonts.notoSansLao(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'ຕໍາແໜ່ງເຂົ້າ: ${messageData['checkOutLocation']}',
                                          style: GoogleFonts.notoSansLao(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'ຕໍາແໜ່ງອອກ: ${messageData['checkInLocation']}',
                                          style: GoogleFonts.notoSansLao(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        TextButton(
                                          onPressed: () {
                                            print('Button pressed');
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: getStatusColor(messageData['status']),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            'ສະຖານະ: ${messageData['status']}',
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
              );
            },
          ),
        ),
      ],
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


















