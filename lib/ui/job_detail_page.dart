import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/models/recent_model.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/theme/images.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

List<Widget> savedJobList = List.empty();
bool isSaved = false;
FirebaseFirestore firestore = FirebaseFirestore.instance;
List<Map<String, dynamic>> dataList = [];
bool flag = true;

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
  }

  RecentModel _controller = Get.find();
  Future<void> GetData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('added_jobs')
            .get();
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (Get.arguments == data["jobs_id"] && flag) {
            setState(() {
              dataList.add(data);
            });
            flag = false;
          }
        });

        print('Veri Çekildi');
        // dataList içindeki verileri kullanabilirsiniz
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(Images.gitlab, height: 40),
              SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    !dataList.isEmpty ? dataList[0]["Title"] : "",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KColors.title,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    !dataList.isEmpty ? dataList[0]["Subtitle"] : "",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: KColors.subtitle,
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 32),
          Row(
            children: [
              _headerStatic(
                "Salary",
                !dataList.isEmpty ? dataList[0]["Salary"] : "",
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
            //dataList[0]["Descriptipn"]
            "You will be Gitlab's dedicated UI/Ux designer, reporting to the chief Technology Officer. You will come up with the user experience for few product features, including developing conceptual design to test with clients and then. Share the...",
            style: TextStyle(fontSize: 14, color: KColors.subtitle),
          ),
          TextButton(
            onPressed: () {},
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero)),
            child: Text("Learn more",
                style: TextStyle(fontSize: 14, color: KColors.primary)),
          )
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
              onPressed: () {},
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
              onPressed: () {
                setState(() {
                  isSaved = !isSaved;
                });
              },
              style: ButtonStyle(
                iconColor: MaterialStateProperty.all(Colors.green),
                side: MaterialStateProperty.all(
                  BorderSide(color: KColors.primary),
                ),
              ),
              child: Icon(
                dataList[0]["isSaved"] ? Icons.bookmark : Icons.bookmark_border,
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
    GetData();
    Future.delayed(Duration(seconds: 5));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.background,
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 1,
        actions: [
          IconButton(icon: Icon(Icons.cloud_upload_outlined), onPressed: () {})
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          _jobDescription(context),
          _ourPeople(context),
          _apply(context)
        ],
      ),
    );
  }
}
