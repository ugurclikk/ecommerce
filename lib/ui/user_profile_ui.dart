import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:get/get.dart';

import '../theme/colors.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:file_selector/file_selector.dart';

import 'job_detail_page.dart';

String name = "";
String surname = "";
String phoneNumber = "";
String cvUrl = "";

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _surnameController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();

  String _pdf = "";

  late html.File imageFile;
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Firestore'dan kullanıcı bilgilerini çek
        DocumentSnapshot userInfoSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection("profile_info")
            .doc(uid)
            .get();

        if (userInfoSnapshot.exists) {
          // Firestore'dan alınan verileri kullanarak bir nesne oluştur
          Map<String, dynamic> userData =
              userInfoSnapshot.data() as Map<String, dynamic>;
          setState(() {
            name = userData['name'];
            surname = userData['surname'];
            phoneNumber = userData['phoneNumber'];
            cvUrl = userData['cv_url'];
          });

          print(userData);
          // Oluşturulan nesneyi kullanarak istediğiniz işlemleri gerçekleştirin
          // Örneğin, bir AlertDialog gösterin
          /* showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('User Information'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
              );
            },
          );*/
        } else {
          print('Kullanıcı bilgileri bulunamadı');
        }
      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _getImageAndUploadToFirebase() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'application/pdf';
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
          _pdf = reader.result as String;
        });
      });
    });
  }

  void _saveProfile(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();

    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name and surname fields cannot be empty.'),
        ),
      );
      return;
    }

    if (phoneNumber.isNotEmpty && !isNumeric(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The number must contain only numeric characters.'),
        ),
      );
      return;
    }

    // Firestore'a kullanıcı bilgilerini ekle
    //await uploadImageToFirebaseStorage(imageFile);

    // PDF yükleniyorsa Firebase Storage'a yükle
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  Future<String?> uploadImageToFirebaseStorage(html.File file) async {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();

    // Firestore'a kullanıcı bilgilerini ekle

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
          FirebaseStorage.instance.ref().child('users/$uid/cv.pdf');
      UploadTask uploadTask = storageRef.putData(fileBytes);

      TaskSnapshot snapshot = await uploadTask;
      _pdf = await snapshot.ref.getDownloadURL();
      String link = "";

      if (_pdf != "") {
        setState(() {
          link = _pdf;
        });
        uploadTask.whenComplete(() async {
          // Dosyanın indirme URL'sini al

          // Indirme URL'sini kullanarak Firebase Firestore'a kaydet
          ;
          String uid = "";
          User? user = await FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Kullanıcının UID'sini al
            uid = user.uid;
          }
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection("profile_info")
              .doc(uid)
              .set({
            'name': name,
            'surname': surname,
            'phoneNumber': phoneNumber,
            'cv_url': link,
          });

          // Profil başarıyla kaydedildi, giriş alanlarını temizle
          //Get.to(UserProfilePage());
         
          setState(() {
            _nameController.clear();
            _surnameController.clear();
            _phoneNumberController.clear();
            _pdf = "";
          });
           await getData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile saved successfully.'),
            ),
          );
          print('PDF yükleme ve Firestore kaydı tamamlandı');
        });
      }

      print('File uploaded to Firebase Storage. Download URL: $_pdf');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(HomePage());
          },
        ),
        backgroundColor: KColors.primary,
        title: Text('User Profile'),
      ),
      body: Container(
        color: KColors.background,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Surname: $surname',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Phone Number: $phoneNumber',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'CV URL: $cvUrl',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            Text(
              'Name:',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: name,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Surname:',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                hintText: surname,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Phone Number:',
              style: TextStyle(
                color: KColors.title,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: phoneNumber,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _getImageAndUploadToFirebase();
                    // _saveProfile(context);
                  },
                  child: Text('Select CV(pdf)'),
                ),
                _pdf.isNotEmpty ? Text("   Pdf is Uploaded") : Text(""),
              ],
            ),
            SizedBox(height: 16.0),
            _pdf != ""
                ? ElevatedButton(
                    onPressed: () async {
                      _saveProfile(context);
                      await uploadImageToFirebaseStorage(imageFile);
                    },
                    child: Text('Save'),
                  )
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12)),
                    height: 28,
                    width: 50,
                    child: Center(child: Text('Save'))),
          ],
        ),
      ),
    );
  }
}
