import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/models/recent_model.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';
import 'package:get/get.dart';

bool flags = true;

class SearchBarr extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchBarr(
      {Key? key, this.onChanged, this.hintText = 'What are you looking for?'})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarr> {
  TextEditingController _controller = TextEditingController();
  RecentModel controller = Get.put(RecentModel());
  late Future<void> _searchFuture;

  void _onTextChanged() async{
    
      print(_controller.text);
      await GetDatasearch();
    
  }

  Future<void> GetDatasearch() async {
    try {
      int addedCount = 0;
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('added_jobs').get();

          addedJobsSnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String title = data["Title"];
            if (_controller.text.toUpperCase() ==
                title
                    .substring(
                        0,
                        _controller.text.length < title.length
                            ? _controller.text.length
                            : title.length)
                    .toUpperCase()) {
              addedCount++;
              if (addedCount > 0 && controller.listlengt() < addedCount) {
                controller.addList(
                    data["Image URL"],
                    data["Title"],
                    data["Subtitle"],
                    data["Salary"].toString(),
                    data["jobs_id"],data["Description"],data["Location"],
            data["job_type"]);
              }
            }
          });
        }
      });
      print('Veri Çekildi-search');
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> GetDataAll() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('added_jobs').get();

          addedJobsSnapshot.docs.forEach((doc) {
            if (flags) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              controller.addList(data["Image URL"], data["Title"],
                  data["Subtitle"], data["Salary"].toString(), data["jobs_id"],data["Description"],data["Location"],
            data["job_type"]);
            }
          });
        }
      });

      print('Veri Çekildi-search');
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _controller,
        onChanged: (value) async {
          if (value.isEmpty) {
            setState(() {
              controller.list.clear();
            });

            await Future.delayed(Duration(seconds: 2));
            await GetDataAll();
            flag = false;
          } else { 
            
            controller.clearlist();
             await Future.delayed(Duration(seconds: 2));
            
              flag = true;
             
              _onTextChanged();
            
          }
        },
        decoration: InputDecoration(
          labelText: widget.hintText,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
