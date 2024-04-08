import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/theme/images.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';
import 'package:flutter_job_portal/ui/login_register.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/recent_model.dart';
import 'add_jobs.dart';
import 'saved_jobs.dart';

List<Widget> recentJobglobal = List.empty();
List<Widget> savedJobListt = List.empty();
FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RecentModel _controller = Get.put(RecentModel());
  @override
  void initState() {
    super.initState();
    GetDatas();
  }

  Future<void> GetDatas() async {
    RecentModel _control = Get.find();
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      usersSnapshot.docs.forEach((userDoc) async {
        if (userDoc.exists) {
          QuerySnapshot addedJobsSnapshot =
              await userDoc.reference.collection('added_jobs').get();
          addedJobsSnapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            setState(() {
              _control.addList(data["Image URL"], data["Title"],
                  data["Subtitle"], data["Salary"], data["jobs_id"]);
            });
          });
        }
      });
      print('Veri Çekildi');
      // dataList içindeki verileri kullanabilirsiniz
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.clearlist();
    super.dispose();
  }

  Widget _appBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(Images.user1),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.home_outlined, color: KColors.primary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border_rounded, color: KColors.icon),
            onPressed: () {
              setState(() {
                Get.to(SavedJobs());
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded, color: KColors.icon),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final FirebaseAuth _auth = FirebaseAuth.instance;
              await _auth.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRegisterPage()),
                );
              });
            },
          )
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello",
              style: TextStyle(
                fontSize: 15,
                color: KColors.subtitle,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 6,
          ),
          Text("Find your perfect job",
              style: TextStyle(
                  fontSize: 20,
                  color: KColors.title,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: KColors.lightGrey,
                        borderRadius: BorderRadius.circular(5)),
                    child:
                        SearchBar() /* Text(
                    "What are you looking for?",
                    style: TextStyle(fontSize: 15, color: KColors.subtitle),
                  ),*/
                    ),
              ),
              SizedBox(
                width: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  color: KColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                height: 40,
                child: IconButton(
                  color: KColors.primary,
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              )
            ],
          )
        ],
      ),
    );
  }
/*
  Widget _recommendedSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: EdgeInsets.symmetric(vertical: 12),
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended",
            style: TextStyle(fontWeight: FontWeight.bold, color: KColors.title),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: savedJobListt.length,
              itemBuilder: (BuildContext context, int index) {
                return savedJobListt[index];
                //todo
              },
            ),
          ),
        ],
      ),
    );
  }
*/

  Widget _recommendedJob(
    BuildContext context, {
    required String img,
    required String company,
    required String title,
    required String sub,
    required bool isSaved,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, JobDetailPage.getJobDetail());
        },
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? KColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : KColors.lightGrey,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Image.asset(img),
                ),
                SizedBox(height: 16),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.white38 : KColors.subtitle,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.white : KColors.title,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.white38 : KColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentPostedJob(BuildContext context) {
    /* List<Widget> recentJobList = [
      _jobCard(context,
          img: Images.gitlab,
          title: "Gitlab",
          subtitle: "UX Designer",
          salery: "\$78,000"),
      _jobCard(context,
          img: Images.bitbucket,
          title: "Bitbucket",
          subtitle: "UX Designer",
          salery: "\$45,000"),
      _jobCard(context,
          img: Images.slack,
          title: "Slack",
          subtitle: "UX Designer",
          salery: "\$65,000"),
      _jobCard(context,
          img: Images.dropbox,
          title: "Dropbox",
          subtitle: "UX Designer",
          salery: "\$95,000"),
    ];
    recentJobglobal = recentJobList;*/
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent posted",
            style: TextStyle(fontWeight: FontWeight.bold, color: KColors.title),
          ),
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _controller.listlengt(),
              itemBuilder: (BuildContext context, int index) {
                return _controller.list[index];
              },
            ),
          ),
        ],
      ),
    );
  }

/*
  Widget _jobCard(
    BuildContext context, {
    required String img,
    required String title,
    required String subtitle,
    required String salery,
  }) {
    RecentModel _control = Get.find();
    String seachTitle = title;
    return GestureDetector(
      onTap: () {
        Get.to(JobDetailPage.getJobDetail());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: KColors.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(img),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: KColors.subtitle),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 14,
                      color: KColors.title,
                      fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: KColors.background,
        onPressed: () {
          Get.to(InputPage());
        },
        child: Icon(Icons.add),
      ),
      backgroundColor: KColors.background,
      //bottomNavigationBar: BottomMenuBar(),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar(context),
                _header(context),
                // _recommendedSection(context),
                _recentPostedJob(context)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
