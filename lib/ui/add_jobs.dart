import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/recent_model.dart';
import 'package:firebase_core/firebase_core.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
TextEditingController _titleController = TextEditingController();
TextEditingController _subtitleController = TextEditingController();
TextEditingController _salaryController = TextEditingController();
TextEditingController _descriptionController = TextEditingController();
final _formKey = GlobalKey<FormState>();
String id = "";
String url = "";
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
      await collectionReference.doc(uid).collection("added_jobs").add(data);

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
  String Description = "";
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

  Future<String?> uploadImageToFirebaseStorage(html.File file) async {
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
      String str = generateUID();
      // Upload to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('users/$uid/jobImage-$str.jpg');
      UploadTask uploadTask = storageRef.putData(fileBytes);

      TaskSnapshot snapshot = await uploadTask;
      imgUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        url = imgUrl;
      });

      print('File uploaded to Firebase Storage. Download URL: $imgUrl');
      return imgUrl;
    }
  }

  String generateUID() {
    var uuid = Uuid();
    return uuid.v4();
  }

  String generateShortUuid() {
    var uuid = Uuid();
    var base64Uuid = base64Url.encode(uuid.v4().codeUnits);
    return base64Uuid.substring(0, 4); // Örneğin, ilk 8 karakteri alıyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.background,
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 0,
        centerTitle: true,
        title: Text('Jobs Detail Form'),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('lib/images/jobs.jpg'),
          fit: BoxFit.fitWidth,
        )),
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color.fromARGB(141, 62, 97, 237)),
            width: 600,
            height: 700,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await _getImageAndUploadToFirebase();
                        }, // Fotoğraf seçme işlevi buraya ekleniyor
                        child: Container(
                          width: 150,
                          height: 150,
                          color: KColors.background,
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
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      
                      controller: _titleController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle:
                            TextStyle(color: Colors.black38, fontSize: 20),
                        labelText: 'Title',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      
                      controller: _subtitleController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle:
                            TextStyle(color: Colors.black38, fontSize: 20),
                        labelText: 'Subtitle',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Subtitle';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          subtitle = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _salaryController,
                      
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle:
                            TextStyle(color: Colors.black38, fontSize: 20),
                        labelText: 'Salary',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Salary';
                        }
                        if (!(value.isNum)) {
                          return 'Please enter numbers';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          salary = value;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 6,
                      minLines: 6,
                      
                      decoration: InputDecoration(
                        //isDense: true,
                        //contentPadding: EdgeInsets.fromLTRB(0, 150, 150, 0),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle:
                            TextStyle(color: Colors.black38, fontSize: 20),
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Description';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          Description = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            print("debug");
                          }
                          id = generateUID();
                          String? imageurl =
                              await uploadImageToFirebaseStorage(imageFile);
                          // Formu göndermek için buraya gerekli işlemleri ekleyin
                          Map<String, dynamic> formData = {
                            "jobs_id": id,
                            'Image URL': imageurl,
                            'Title': title,
                            'Subtitle': subtitle,
                            'Salary': salary,
                            'Description': Description,
                            "isSaved": false
                          };
                          _controller.clearlist();
                          addDataToFirestore(formData).then(
                              (value) => Get.to(HomePage(), arguments: id));

                          /*setState(() {
                            _controller.addList(imgUrl, title, subtitle, salary,id);
                            flag = !flag;
                          });*/
                          Get.to(HomePage(), arguments: id);
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
