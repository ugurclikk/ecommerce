import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/recent_model.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
String id = "";
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

Future<void> addDataToFirestore(Map<String, dynamic> data) async {
  try {
    // Kullanıcıyı al
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kullanıcının UID'sini al
      String uid = user.uid;

      // Firestore koleksiyon referansı oluştur
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('users');

      // Kullanıcının UID'siyle belge oluştur
      await collectionReference.doc(uid).set(data);

      print('Veri eklendi');
    } else {
      print('Kullanıcı giriş yapmamış');
    }
  } catch (e) {
    print('Hata: $e');
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  RecentModel _controller = Get.find();
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kullanıcının UID'sini al
      String uid = user.uid;

      // Storage referansı oluştur

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoadEnd.first;
      final Uint8List fileBytes = reader.result as Uint8List;

      //final fileName = file.name;

      // Upload to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('users/$uid/jobImage.jpg');
      UploadTask uploadTask = storageRef.putData(fileBytes);

      TaskSnapshot snapshot = await uploadTask;
      imgUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imgUrl = imgUrl;
      });
      print('File uploaded to Firebase Storage. Download URL: $imgUrl');
    }
  }

  String generateUID() {
    var uuid = Uuid();
    return uuid.v4();
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
                  "jobs_id": id,
                  'Image URL': imgUrl,
                  'Title': title,
                  'Subtitle': subtitle,
                  'Salary': salary,
                };
                await uploadImageToFirebaseStorage(imageFile);
                addDataToFirestore(formData);
                /*setState(() {
                  _controller.addList(imgUrl, title, subtitle, salary,id);
                  flag = !flag;
                });*/
                Get.to(HomePage(), arguments: id);
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
