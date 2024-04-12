import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/models/recent_model.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/theme/images.dart';
import 'package:flutter_job_portal/ui/add_jobs.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'job_application.dart';

List<Widget> savedJobList = List.empty();
bool isSaved = false;
FirebaseFirestore firestore = FirebaseFirestore.instance;
List<Map<String, dynamic>> dataList = [];
bool flag = true;
bool SavedFlag = true;
String job_id = "";

class JobDetailPage extends StatefulWidget {
  JobDetailPage({Key? key}) : super(key: key);

  static Route<T> getJobDetail<T>() {
    return MaterialPageRoute(
      builder: (_) => JobDetailPage(),
    );
  }

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dataList.clear();
    flag = true;
    isSaved = false;
  }

  RecentModel _controller = Get.find();
  Future<void> GetData() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        String currentID = "";
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('added_jobs').get();
          addedJobsSnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            setState(() {
              if (Get.arguments == data["jobs_id"] && flag) {
                setState(() {
                  // print(data);
                  dataList.add(data);
                  currentID = data["jobs_id"];
                  job_id = data["jobs_id"];
                });
                flag = false;
              }
            });
          });
        }
        String uid = "";
        User? user = await FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Kullanıcının UID'sini al
          uid = user.uid;

          QuerySnapshot savedJobsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection("saved_jobs")
              .get();
          savedJobsSnapshot.docs.forEach((doc) {
            Map<String, dynamic> savedData = doc.data() as Map<String, dynamic>;
            if (savedData["jobs_id"] == currentID) {
              print(savedData);
              setState(() {
                isSaved = savedData["isSaved"];
              });
            }
          });
        }
      });
      print(isSaved);
      print('Veri Çekildi-Detail');
      // dataList içindeki verileri kullanabilirsiniz
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    print("init");
    GetData();
    Future.delayed(Duration(seconds: 5));
    super.initState();
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(dataList[0]["Image URL"], height: 40),
              SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !dataList.isEmpty
                      ? Text(dataList[0]["Title"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: KColors.title,
                          ))
                      : CircularProgressIndicator(),
                  SizedBox(height: 5),
                  !dataList.isEmpty
                      ? Text(
                          dataList[0]["Subtitle"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: KColors.subtitle,
                          ),
                        )
                      : CircularProgressIndicator()
                ],
              )
            ],
          ),
          SizedBox(height: 32),
          Row(
            children: [
              _headerStatic(
                "Salary",
                !dataList.isEmpty ? dataList[0]["Salary"].toString() : "",
              ),
              _headerStatic("Applicants",
                  "45"), //todo add storage and increase every applying
              // _headerStatic(
              //    "Salary", !dataList.isEmpty ? dataList[0]["Salary"] : ""),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child:
                    Image.asset(Images.doc, height: 20, color: KColors.primary),
              ),
              Expanded(
                child:
                    Image.asset(Images.museum, height: 20, color: KColors.icon),
              ),
              /*Expanded(
                child:
                    Image.asset(Images.clock, height: 20, color: KColors.icon),
              ),
              Expanded(
                child: Image.asset(Images.map, height: 20, color: KColors.icon),
              ),*/
            ],
          ),
          Divider(
            color: KColors.icon,
            height: 25,
          )
        ],
      ),
    );
  }

  Widget _headerStatic(String title, String sub) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: KColors.subtitle,
            ),
          ),
          SizedBox(height: 5),
          Text(
            sub,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: KColors.title,
            ),
          )
        ],
      ),
    );
  }

  Widget _jobDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Job Description", //dataList[0]["Descriptipn"]
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            dataList[0]["Description"],
            //"You will be Gitlab's dedicated UI/Ux designer, reporting to the chief Technology Officer. You will come up with the user experience for few product features, including developing conceptual design to test with clients and then. Share the...",
            style: TextStyle(fontSize: 14, color: KColors.subtitle),
          ),
          /*TextButton(
            onPressed: () {},
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero)),
            child: Text("Learn more",
                style: TextStyle(fontSize: 14, color: KColors.primary)),
          )*/
        ],
      ),
    );
  }

  Widget _ourPeople(BuildContext context) {
    return Container(
      height: 92,
      padding: EdgeInsets.only(left: 16),
      margin: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Our People",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _people(context, img: Images.user1, name: "J. Smith"),
                _people(context, img: Images.user2, name: "L. James"),
                _people(context, img: Images.user3, name: "Emma"),
                _people(context, img: Images.user4, name: "Mattews"),
                _people(context, img: Images.user5, name: "Timothy"),
                _people(context, img: Images.user6, name: "Kyole"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _people(BuildContext context,
      {required String img, required String name}) {
    return Container(
      margin: EdgeInsets.only(right: 18),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(img),
          ),
          SizedBox(height: 8),
          Text(name, style: TextStyle(fontSize: 8, color: KColors.subtitle)),
        ],
      ),
    );
  }

  Widget _apply(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(top: 54),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(KColors.primary),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16))),
              onPressed: () {
                Get.to(JobApplicationPage(), arguments: job_id);
              },
              child: Text(
                "Apply Now",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            height: 50,
            width: 60,
            child: OutlinedButton(
              onPressed: () async {
                setState(() {
                  isSaved = !isSaved;
                });

                String uid = "";
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Kullanıcının UID'sini al
                  uid = user.uid;
                }
                Map<String, dynamic> savedMap = {
                  "jobs_id": dataList[0]["jobs_id"],
                  'Image URL': dataList[0]["Image URL"],
                  'Title': dataList[0]["Title"],
                  'Subtitle': dataList[0]["Subtitle"],
                  'Salary':int.parse( dataList[0]["Salary"]),
                  'Description': dataList[0]["Description"],
                  "isSaved": isSaved,
                };
                if (isSaved) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection("saved_jobs")
                      .doc(dataList[0]["jobs_id"])
                      .set(savedMap);
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection("saved_jobs")
                      .doc(dataList[0]["jobs_id"])
                      .delete();
                }
              },
              style: ButtonStyle(
                iconColor: MaterialStateProperty.all(Colors.green),
                side: MaterialStateProperty.all(
                  BorderSide(color: KColors.primary),
                ),
              ),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: KColors.primary,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.background,
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 1,
        actions: [
          //IconButton(icon: Icon(Icons.cloud_upload_outlined), onPressed: () {})
        ],
      ),
      body: dataList.length > 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                _jobDescription(context),
                _ourPeople(context),
                _apply(context)
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
