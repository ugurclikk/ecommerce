import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'models/recent_model.dart';
import 'ui/login_register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // başlarken çek ve kullan bu ikili yapı gerekli
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD-5q8GvQtDDh3dMMWlObIV5nI8LpfVYoU",
          authDomain: "ecommercee-b9bf7.firebaseapp.com",
          projectId: "ecommercee-b9bf7",
          storageBucket: "ecommercee-b9bf7.appspot.com",
          messagingSenderId: "842540677343",
          appId: "1:842540677343:web:f1d3e7e9d97dd42ebf916a",
          measurementId: "G-6Z27V71XMW"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    RecentModel _controller = Get.put(RecentModel());
    return GetMaterialApp(
      title: 'Jobify',
      theme: ThemeData.light(),
      home: HomePage(), //LoginRegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
