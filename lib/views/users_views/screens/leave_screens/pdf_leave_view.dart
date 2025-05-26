import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:admin_timesabai/views/users_views/screens/notification/notification_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class Pdfview extends StatefulWidget {
  final String documentUrl;
  final String? users;
  final String? leaveid;

  const Pdfview({Key? key, required this.documentUrl, this.users, this.leaveid})
      : super(key: key);

  @override
  State<Pdfview> createState() => _PdfviewState();
}

class _PdfviewState extends State<Pdfview> {
  TextEditingController _textController = TextEditingController();

  bool isLoading = true;
  bool isLoadingPop = false;
  PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfSignaturePadState> sf = GlobalKey();
  Color currentColor = Colors.black;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  GlobalKey _repaintBoundaryKey = GlobalKey();
  Offset _signaturePosition =
      Offset(100, 100); // Starting position of the signature
  bool _showSignature = true;
  bool _showImage = true;
  Offset _imagesPosition = Offset(100, 100);

  Uint8List? imageBytes;
  Uint8List? images;
  Uint8List? text;
  Offset _textPosition = Offset(50, 150);
  bool _showText = false;
  String? _textToShow;

  bool _showDate = false;
  Offset _datePosition = Offset(100, 100);
  Size? _pdfPageSize;

  bool isLoadingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
    _addSignatureToPdf();
    // print("Id doc ${ widget.documentUrl}");
    // print("user ID: ${widget.users}");
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}"; // Format as you prefer
  }

  void _showDateDialog() {
    setState(() {
      _showDate = true; // Set to true to show the date
    });
  }

  Future<void> _loadPdf() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  final List<Map<String, dynamic>> iconTextData = [
    {'icon': Icons.edit, 'text': 'Signature', 'string': 'ລາຍເຊັນ'},
    {'icon': Icons.date_range, 'text': 'Date', 'string': 'ວັນທີ'},
    {'icon': Icons.text_fields, 'text': 'Text', 'string': 'ຕົວອັກສອນ'},
    {'icon': Icons.perm_identity, 'text': 'Name', 'string': 'ຊື່'},
    {'icon': Icons.image, 'text': 'Image', 'string': 'ຮູບພາບ'},
  ];

  Future<void> _addSignatureToPdf() async {
    setState(() {
      isLoadingPop = true; // Start loading
    });

    try {
      // Download PDF from URL
      Dio dio = Dio();
      Response response = await dio.get(widget.documentUrl,
          options: Options(responseType: ResponseType.bytes));
      Uint8List pdfBytes = Uint8List.fromList(response.data);

      // Open the downloaded PDF file
      PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      PdfPage page = document.pages[0]; // Select the first page

      // Capture the signature as an image with a transparent background
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List capturedImageBytes = byteData!.buffer.asUint8List();

      // Save the updated PDF to the app directory
      List<int> updatedPdfBytes = await document.save();
      document.dispose();

      // Update the state to display the signature in the current page
      setState(() {
        imageBytes = capturedImageBytes;
      });

      // Optionally, save the updated PDF (but without navigation)
      Directory directory = await getApplicationDocumentsDirectory();
      String newPdfPath = '${directory.path}/updated_signature.pdf';
      File updatedFile = File(newPdfPath);
      await updatedFile.writeAsBytes(updatedPdfBytes);

      // Notify user
      Fluttertoast.showToast(
        msg: 'ເພີ່ມລາຍເຊັນເຂົ້າ ເອກະສານສໍາເລັດ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingPop = false; // Stop loading
      });
    }
  }

  void _showSignatureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              // This will center the text vertically and horizontally
              child: Text(
                'ລາຍເຊັນ',
                style: GoogleFonts.notoSansLao(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          content: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: SfSignaturePad(
                key: _signaturePadKey,
                backgroundColor: Colors.transparent,
                strokeColor: Colors.black,
                minimumStrokeWidth: 1.0,
                maximumStrokeWidth: 4.0,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: ColorPalette(Colors.blue, 10)),
                Expanded(child: ColorPalette(Colors.black26, 10)),
                Expanded(child: ColorPalette(Colors.red, 10)),
                TextButton(
                  onPressed: () {
                    sf.currentState?.clear();
                  },
                  child: Text(
                    'ລືບ',
                    style: GoogleFonts.notoSansLao(),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoadingPop
                      ? null
                      : () async {
                          await _addSignatureToPdf();
                          Navigator.pop(context);
                        },
                  child: isLoadingPop
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "ບັນທືກ",
                          style: GoogleFonts.notoSansLao(),
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _addImageToPdf(Uint8List imageBytes) async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(widget.documentUrl,
          options: Options(responseType: ResponseType.bytes));
      Uint8List pdfBytes = Uint8List.fromList(response.data);

      // Load the PDF document
      PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      PdfPage page = document.pages[0];

      // Add image to the PDF page
      PdfBitmap bitmap = PdfBitmap(imageBytes);
      page.graphics.drawImage(
          bitmap,
          Rect.fromLTWH(
              50, 50, 100, 100)); // Adjust position and size as needed

      // Save the updated PDF
      List<int> updatedPdfBytes = await document.save();
      document.dispose();

      // Save the updated PDF file to the app directory
      Directory directory = await getApplicationDocumentsDirectory();
      String newPdfPath = '${directory.path}/updated_image.pdf';
      File updatedFile = File(newPdfPath);
      await updatedFile.writeAsBytes(updatedPdfBytes);

      // Update the images state if necessary (optional, depending on how you use 'images')
      setState(() {
        images =
            imageBytes; // If you need the raw image bytes, you can store it here
      });

      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image added to PDF and saved.')));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addTextToPdf(String text) async {
    try {
      // Download PDF from URL
      Dio dio = Dio();
      Response response = await dio.get(widget.documentUrl,
          options: Options(responseType: ResponseType.bytes));
      Uint8List pdfBytes = Uint8List.fromList(response.data);

      // Load the PDF document
      PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      PdfPage page = document.pages[0];

      // Set up font and style
      PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      PdfBrush brush = PdfSolidBrush(PdfColor(0, 0, 0));

      // Add text to the PDF page at position (x, y)
      page.graphics.drawString(
        text,
        font,
        brush: brush,
        bounds: Rect.fromLTWH(
            50, 150, 300, 20), // Adjust position and size as needed
      );

      // Save the updated PDF
      List<int> updatedPdfBytes = await document.save();
      document.dispose();

      // Save the updated PDF file to the app directory
      Directory directory = await getApplicationDocumentsDirectory();
      String newPdfPath = '${directory.path}/updated_text.pdf';
      File updatedFile = File(newPdfPath);
      await updatedFile.writeAsBytes(updatedPdfBytes);

      // Update the state to show the added text
      setState(() {
        _textToShow = text; // Save the text to show
        _showText = true; // Show the text
      });

      // Notify user
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Text added to PDF.')));
    } catch (e) {
      print(e);
    }
  }

  void _showTextDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter text to add to PDF',
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    sf.currentState?.clear();
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String textToAdd = _textController.text;

                    if (textToAdd.isNotEmpty) {
                      await _addTextToPdf(textToAdd);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter some text')));
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePdf() async {
    setState(() {
      isLoadingPdf = true;
    });
    try {
      Response response = await Dio().get(widget.documentUrl,
          options: Options(responseType: ResponseType.bytes));
      List<int> pdfBytes = response.data;

      PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      PdfPage page = document.pages[0];

      final double pdfPageWidth = page.size.width;
      final double pdfPageHeight = page.size.height;

      final screenSize = MediaQuery.of(context).size;

      double scaleX = pdfPageWidth / screenSize.width;
      double scaleY = pdfPageHeight / screenSize.height;

      double signatureWidth = 100;
      double signatureHeight = 50;
      double imageWidth = 50;
      double imageHeight = 50;
      double textHeight = 20;
      double dateHeight = 10;

      double adjustedSignatureX = _signaturePosition.dx * scaleX;
      double adjustedSignatureY = pdfPageHeight - signatureHeight - 30;

      if (imageBytes != null) {
        final PdfBitmap signatureBitmap = PdfBitmap(imageBytes!);
        page.graphics.drawImage(
          signatureBitmap,
          Rect.fromLTWH(adjustedSignatureX, adjustedSignatureY,
              signatureWidth * scaleX, signatureHeight * scaleY),
        );
      }

      double adjustedImageX = _imagesPosition.dx * scaleX;
      double adjustedImageY = pdfPageHeight - imageHeight - 30;

      if (images != null) {
        final PdfBitmap imageBitmap = PdfBitmap(images!);
        page.graphics.drawImage(
          imageBitmap,
          Rect.fromLTWH(adjustedImageX, adjustedImageY, imageWidth * scaleX,
              imageHeight * scaleY),
        );
      }

      double adjustedTextX = _textPosition.dx * scaleX;
      double adjustedTextY = pdfPageHeight - textHeight - 30;

      if (_textToShow != null) {
        final PdfFont font =
            PdfStandardFont(PdfFontFamily.helvetica, 20 * scaleY);
        page.graphics.drawString(
          _textToShow!,
          font,
          bounds: Rect.fromLTWH(
              adjustedTextX, adjustedTextY, page.size.width, page.size.height),
        );
      }
      double adjustedDateX = _datePosition.dx * scaleX;
      double adjustedDateY = pdfPageHeight - dateHeight - 30;

      final PdfFont dateFont =
          PdfStandardFont(PdfFontFamily.helvetica, 10 * scaleY);
      page.graphics.drawString(
        _getCurrentDate(),
        dateFont,
        bounds: Rect.fromLTWH(
            adjustedDateX, adjustedDateY, page.size.width, page.size.height),
      );

      // Save the updated PDF to a byte array
      List<int> updatedPdfBytes = await document.save();
      document.dispose();

      // Save the file to local storage
      Directory directory = await getApplicationDocumentsDirectory();
      String newPdfPath = '${directory.path}/final_updated_document.pdf';
      File updatedFile = File(newPdfPath);
      await updatedFile.writeAsBytes(updatedPdfBytes);

      // Upload the updated PDF to Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          'leave_documents/updated_document_${DateTime.now().millisecondsSinceEpoch}.pdf');
      UploadTask uploadTask = ref.putFile(updatedFile);

      // Get the download URL after the upload is complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      String? leaveDocId = await _getLeaveDocumentId(widget.users!);

      if (leaveDocId == null) {
        print('No leave document found for user: ${widget.users}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No leave document found.')));
        return; // Exit if no document to update
      }

      await FirebaseFirestore.instance
          .collection('Employee')
          .doc(widget.users)
          .collection('Leave')
          .doc(widget.leaveid)
          .update({'documentUrl': downloadUrl, 'status': "ອະນຸມັດແລ້ວ"});
      print("LeaveID🤮🤮${leaveDocId}");

      Fluttertoast.showToast(
        msg: 'ເຊັນໃບລາພັກສໍາລັດ !!!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {
        isLoadingPdf = false;
      });
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save PDF.')));
      setState(() {
        isLoadingPdf = false; // Hide loading indicator
      });
    }
  }

  Future<String?> _getLeaveDocumentId(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(userId)
        .collection('Leave')
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  Future<void> _pickImageAndAddToPdf() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      _addImageToPdf(imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'ເອກະສານຂໍລາພັກ',
          style: GoogleFonts.notoSansLao(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _savePdf().whenComplete(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreens(),
                  ),
                );
              });
            },
            icon: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: const Icon(IonIcons.save)),
          ),
        ],
        backgroundColor: const Color(0xFF577DF4),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? Center(
                  child: LoadingAnimationWidget.inkDrop(
                    size: 50,
                    color: Colors.orange,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SfPdfViewer.network(
                            widget
                                .documentUrl, // Use network to load PDF from URL
                            controller: _pdfViewerController,
                            onDocumentLoaded: (details) {
                              setState(() {
                                _pdfPageSize = details.document.pages[0].size;
                              });
                            },
                          ),
                          if (_showSignature &&
                              imageBytes != null &&
                              _pdfPageSize != null)
                            Positioned(
                              left: _signaturePosition.dx,
                              top: _signaturePosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _signaturePosition += details.delta;
                                  });
                                },
                                child: Image.memory(
                                  imageBytes!,
                                  width: 100,
                                  height: 50,
                                ),
                              ),
                            ),
                          if (_showImage &&
                              images != null &&
                              _pdfPageSize != null)
                            Positioned(
                              left: _imagesPosition.dx,
                              top: _imagesPosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _imagesPosition += details.delta;
                                  });
                                },
                                child: Image.memory(
                                  images!,
                                  width: 100,
                                  height: 50,
                                ),
                              ),
                            ),
                          if (_showText &&
                              _textToShow != null &&
                              _pdfPageSize != null)
                            Positioned(
                              left: _textPosition.dx,
                              top: _textPosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _textPosition += details
                                        .delta; // Update position based on drag
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  // Make the container transparent
                                  child: Text(
                                    _textToShow!, // Display the text
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          if (_showDate && _pdfPageSize != null)
                            // Show the date if the condition is true
                            Positioned(
                              left: _datePosition.dx,
                              top: _datePosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _datePosition += details
                                        .delta; // Update position based on drag
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  // Make the container transparent
                                  child: Text(
                                    _getCurrentDate(), // Display the current date
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: iconTextData.map((item) {
                            return GestureDetector(
                              onTap: () {
                                if (item['text'] == 'Signature') {
                                  _showSignatureDialog(); // Show dialog on tap
                                }
                                if (item['text'] == 'Image') {
                                  _pickImageAndAddToPdf(); // Show dialog on tap
                                }
                                if (item['text'] == 'Text') {
                                  _showTextDialog(); // Show dialog on tap
                                }
                                if (item['text'] == 'Date') {
                                  _showDateDialog(); // Show dialog on tap
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: Colors.white, width: 8),
                                    ),
                                    child: Center(
                                      child: Icon(item['icon']),
                                    ),
                                  ),
                                  Text(
                                    item['string'],
                                    style: GoogleFonts.notoSansLao(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
          if (isLoadingPdf)
            Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: LoadingAnimationWidget.inkDrop(
                  size: 50,
                  color: Colors.orange,
                )))
        ],
      ),
    );
  }

  Widget ColorPalette(Color color, double size) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentColor = color;
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: color,
      ),
      child: null,
    );
  }
}
