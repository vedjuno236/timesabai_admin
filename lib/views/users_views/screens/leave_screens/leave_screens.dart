import 'package:admin_timesabai/service/leave_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LeaveScreens extends StatefulWidget {
  const LeaveScreens({super.key});

  @override
  State<LeaveScreens> createState() => _LeaveScreensState();
}

class _LeaveScreensState extends State<LeaveScreens> {
  final LeaveService _firestoreService = LeaveService();
  List<DocumentSnapshot>? users;
  String searchText = '';
  bool isSearchClicked = false;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedDate;
  String _date = DateFormat('dd MMMM ').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    users = await _firestoreService.getUsers(searchText: searchText);
    setState(() {});
  }

  Future<void> _seteDate() async {
    DateTime? selectedDay = await showRoundedDatePicker(
      context: context,
      theme: ThemeData.dark(),
    );

    if (selectedDay != null) {
      final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
      String formattedDate = dateFormat.format(selectedDay);

      setState(() {
        _selectedDate = formattedDate;
        _date = DateFormat('dd MMMM').format(selectedDay);
      });

      await _fetchUsers();
    }
  }

  void _updateStatus(String userId, String messageId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('Employee')
        .doc(userId)
        .collection('Leave')
        .doc(messageId)
        .update({'status': newStatus});

    setState(() {
      // Refresh the UI or fetch data again if needed
      _fetchUsers();
    });
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
          'ຂໍ້ມູນມາລາພັກ',
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () async {
                  _seteDate();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFF193940),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white),
                      const SizedBox(width: 8),
                      Text( "ເລືອກວັນທີ:${_date.isEmpty ? "ເລືອກວັນທີ" : _date}",
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
              ),),

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
                  String userId = users![index].id;

                  return ExpansionTile(
                    title: Text(
                      "ຊື່ : ${userData['name'] ?? 'Unnamed User'}",
                      style: GoogleFonts.notoSansLao(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:  const Color(0xFFF193940),
                      ),
                    ),
                    children: [
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: _firestoreService.getUserMessages(userId,date: _selectedDate),
                        builder: (context, messagesSnapshot) {
                          if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                            return  ListTile(title: Text('ກໍາລັງໂຫລດຂໍ້ມູນ...',style: GoogleFonts.notoSansLao(fontSize: 15)));
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
                                    final messageData = messages[messageIndex].data() as Map<String, dynamic>;
                                    DateTime fromDate = (messageData['fromDate'] as Timestamp).toDate();
                                    DateTime toDate = (messageData['toDate'] as Timestamp).toDate();
                                    DateTime Date = (messageData['date'] as Timestamp).toDate();
                                    String formattedFromDate = DateFormat('dd MMMM yyyy ').format(fromDate);
                                    String formattedToDate = DateFormat('dd MMMM yyyy ').format(toDate);
                                    String formattedDate = DateFormat('dd MMMM yyyy ').format(Date);

                                    return ExpansionTile(
                                      title: Text(
                                        'ວັນທີ: $formattedDate',
                                        style: GoogleFonts.notoSansLao(fontSize: 15),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ຈາກວັນທີ: $formattedFromDate',
                                                style: GoogleFonts.notoSansLao(fontSize: 15),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'ວັນທີສີ້ນສຸດ: $formattedToDate',
                                                style: GoogleFonts.notoSansLao(fontSize: 15),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${messageData['daySummary']}',
                                                style: GoogleFonts.notoSansLao(fontSize: 15),
                                              ),

                                              SizedBox(height: 5),
                                              Text(
                                                'ເຫດຜົນ: ${messageData['doc']}',
                                                style: GoogleFonts.notoSansLao(fontSize: 15),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'ປະເພດລາພັກ: ${messageData['leaveType']}',
                                                style: GoogleFonts.notoSansLao(fontSize: 15),
                                              ),
                                              SizedBox(height: 5),
                                              TextButton(
                                                onPressed: () {
                                                  _showEditStatusDialog(messageData['status'], userId, messages[messageIndex].id);
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor: getStatusColor(messageData['status']),
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text(
                                                  'ສະຖານະ: ${messageData['status']}',
                                                  style: GoogleFonts.notoSansLao(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => FullScreenImage(imageUrl: messageData['imageUrl']),
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  messageData['imageUrl'],
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
                                        )
                                      ],
                                    );
                                  },
                                )
                              ] );


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
      case 'ອະນຸມັດແລ້ວ':
        return Colors.blue;
      case 'ປະຕິເສດ':
        return Colors.red;
      default:
        return Colors.orangeAccent;
    }
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
              onPressed: () {
                _updateStatus(userId, messageId, selectedStatus);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

