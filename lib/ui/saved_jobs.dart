import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';
import 'package:get/get.dart';

import '../models/recent_model.dart';

var items = [];

class SavedJobs extends StatefulWidget {
  @override
  State<SavedJobs> createState() => _MyAppState();
}

class _MyAppState extends State<SavedJobs> {
  RecentModel _controller = Get.put(RecentModel());
  Future<void> GetDatas() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('saved_jobs').get();
          addedJobsSnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            setState(() {
              _controller.addSavedList(data["Image URL"], data["Title"],
                  data["Subtitle"], data["Salary"], data["jobs_id"]);
            });
          });
        }
      });
      print('Veri Çekildi-saved');
     
      // dataList içindeki verileri kullanabilirsiniz
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    GetDatas();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Saved Jobs'),
        ),
        body: Obx(
          () => ListView.builder(
            itemCount: _controller.listsavedlengt(),
            itemBuilder: (context, index) {
              return _controller.savedlist[index];
            },
          ),
        ),
      ),
    );
  }
}
