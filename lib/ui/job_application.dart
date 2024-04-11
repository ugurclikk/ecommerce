import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:flutter_job_portal/ui/user_profile_ui.dart';
import 'package:get/get.dart';

import 'job_detail_page.dart';

class JobApplicationPage extends StatefulWidget {
  @override
  _JobApplicationPageState createState() => _JobApplicationPageState();
}

class _JobApplicationPageState extends State<JobApplicationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = "";
  String _surname = "";
  String _CVv = "";
  String _email = "";
  String _phone = "";
  String _resume = "";

  Future<void> putData() async {
    try {
      String uid = "";
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      }

      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('added_jobs').get();

          addedJobsSnapshot.docs.forEach((doc) async {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            print(Get.arguments);
            if (job_id == data["jobs_id"]) {
              print(doc.id);
              await userDoc.reference
                  .collection('added_jobs')
                  .doc(doc.id)
                  .collection("applies")
                  .doc(uid)
                  .set({
                "name": _name,
                "surname": _surname,
                "CV": _CVv,
                "email": _email,
                "phone ": _phone,
                "resume": _resume,
              });
            }
          });
        }
      });

      print('Veri Çekildi-Detail');
      // dataList içindeki verileri kullanabilirsiniz
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> getData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        _email = user.email!;
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
            _name = userData['name'];
            _surname = userData['surname'];
            _phone = userData['phoneNumber'];
            _CVv = userData['cv_url'];
          });

          print(userData);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Application Form'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(HomePage());
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/images/bg.png"), fit: BoxFit.cover)),
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  width: 400,
                  height: 800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Name and Surname:",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: _name + " " + _surname,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            // return 'Please enter your name';
                          } else {
                            _name = value;
                          }
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "E-mail:",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: _email,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            //return 'Please enter your email';
                          } else {
                            _email = value;
                          }
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Phone Number:",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: _phone,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            //return 'Please enter your phone number';
                          } else {
                            _phone = value;
                          }
                          //return null;
                        },
                        onSaved: (value) {
                          _phone = value!;
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Cover Letter:",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Cover Letter',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            //return 'Please upload your Cover Letter';
                          } else {
                            _resume = value;
                          }
                        },
                        onSaved: (value) {
                          _resume = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // _formKey.currentState!.save();
                              // Here you can submit the form data
                              // For now, let's just print it
                              print('Name: $_name');
                              print('Email: $_email');
                              print('Phone: $_phone');
                              print('cover letter: $_resume');
                              if (_CVv.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          "Please Upload your CV in Profile"),
                                    );
                                  },
                                );
                              } else {
                                await putData().then((value) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text("Apply is Succesfull"),
                                      );
                                    },
                                  );
                                });
                              }
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
