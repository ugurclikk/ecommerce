import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<void> downloadFile(String filePath) async {
  try {
    String downloadURL = await storage.ref(filePath).getDownloadURL();
    print('Dosya indirme URL: $downloadURL');
  } catch (e) {
    print('Hata: $e');
  }
}

Future<void> uploadFile(File file) async {
  try {
    String fileName = Path.basename(file.path);
    TaskSnapshot taskSnapshot =
        await storage.ref('uploads/$fileName').putFile(file);
    print('Dosya yüklendi: ${taskSnapshot.ref}');
  } catch (e) {
    print('Hata: $e');
  }
}

Future<void> addData(Map<String, dynamic> Data) async {
  try {
    await firestore.collection('jobs').add(Data);
    print('Veri eklendi');
  } catch (e) {
    print('Hata: $e');
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String img = "";
  String imgUrl = "";
  late html.File imageFile;
  String title = "";
  String subtitle = "";
  String salary = "";
  bool flag = true;
  Future<void> _getImageAndUploadToFirebase() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((event) async {
      final html.File file = input.files!.first;
      imageFile = file;
      // Call the function to upload image to Firebase Storage
      //await uploadImageToFirebaseStorage(file);

      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          img = reader.result as String;
        });
      });
    });
  }

  Future<void> uploadImageToFirebaseStorage(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    await reader.onLoadEnd.first;
    final Uint8List fileBytes = reader.result as Uint8List;

    final fileName = file.name;

    // Upload to Firebase Storage
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putData(fileBytes);

    TaskSnapshot snapshot = await uploadTask;
    imgUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imgUrl = imgUrl;
    });
    print('File uploaded to Firebase Storage. Download URL: $imgUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap:
                  _getImageAndUploadToFirebase, // Fotoğraf seçme işlevi buraya ekleniyor
              child: Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: img.isNotEmpty
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Subtitle'),
              onChanged: (value) {
                setState(() {
                  subtitle = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Salary'),
              onChanged: (value) {
                setState(() {
                  salary = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                // Formu göndermek için buraya gerekli işlemleri ekleyin
                Map<String, dynamic> formData = {
                  'Image URL': imgUrl,
                  'Title': title,
                  'Subtitle': subtitle,
                  'Salary': salary,
                };
                await uploadImageToFirebaseStorage(imageFile);
                addData(formData);
                setState(() {
                  flag = !flag;
                });
              },
              child: Text('Submit'),
            ),
            flag
                ? Placeholder(
                    fallbackHeight: 2,
                  )
                : Image.network(imgUrl),
          ],
        ),
      ),
    );
  }
}
