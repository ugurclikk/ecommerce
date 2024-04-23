import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:flutter_job_portal/theme/images.dart';
import 'package:flutter_job_portal/ui/admin_panel.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';
import 'package:flutter_job_portal/ui/login_register.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/recent_model.dart';
import 'add_jobs.dart';
import 'saved_jobs.dart';
import 'search_bar.dart';
import 'user_profile_ui.dart';

List<Widget> recentJobglobal = List.empty();
List<Widget> savedJobListt = List.empty();
FirebaseFirestore firestore = FirebaseFirestore.instance;
String dropdownValue_name = "Title";
bool dropdownValue_order = false;
List<Map<String, dynamic>> dataListe = [];

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
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      await GetDatas();
    } catch (e) {
      print('Hata: $e');
    }
  }

  Widget dropdownbutton(List<String> list) {
    //const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
    return DropdownMenu<String>(
      leadingIcon: Icon(Icons.onetwothree_rounded),
      trailingIcon: Icon(Icons.arrow_downward_rounded),
      initialSelection: list.first,
      onSelected: (String? value) async {
        // This is called when the user selects an item.
        setState(() {
          switch (value) {
            case "ascending":
              dropdownValue_order = false;
              break;
            case "descending":
              dropdownValue_order = true;
              break;
            case "Salary":
              dropdownValue_name = value!;
              break;
            case "Name":
              dropdownValue_name = "Title";
              break;

            default:
          }
        });
        _controller.clearlist();
        await GetDatas();
      },
      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }

  Future<void> GetDatas() async {
    RecentModel _control = Get.find();
    try {
      dataListe.clear();
      dataList.clear();
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      QuerySnapshot addedJobsSnapshot;
      for (var userDoc in usersSnapshot.docs) {
        //print(userDoc.id);
        if (_controller.selectList[0]) {
          addedJobsSnapshot = await userDoc.reference
              .collection("added_jobs")
              .where('job_type', isEqualTo: 'Remote')
              //.orderBy(dropdownValue_name, descending: dropdownValue_order)
              .get();
        } else if (_controller.selectList[1]) {
          addedJobsSnapshot = await userDoc.reference
              .collection("added_jobs")
              .where('job_type', isEqualTo: 'Face-to-Face')
              //.orderBy(dropdownValue_name, descending: dropdownValue_order)
              .get();
        } else if (_controller.selectList[2]) {
          addedJobsSnapshot = await userDoc.reference
              .collection("added_jobs")
              .where('job_type', isEqualTo: 'Hybrid')
              //.orderBy(dropdownValue_name, descending: dropdownValue_order)
              .get();
        } else {
          addedJobsSnapshot = await userDoc.reference
              .collection("added_jobs")
              //.orderBy(dropdownValue_name, descending: dropdownValue_order)
              .get();
        }
        for (var doc in addedJobsSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print(addedJobsSnapshot.size);
          setState(() {
            dataListe.add(data);
          });
          /*_control.addList(data["Image URL"], data["Title"], data["Subtitle"],
              data["Salary"].toString(), data["jobs_id"]);*/
        }
      }

      if (dropdownValue_name == "Salary") {
        dataListe.sort((a, b) => a["Salary"].compareTo(b["Salary"]));

        if (dropdownValue_order) {
          dataListe = dataListe.reversed.toList();
        }
        for (int j = 0; j < dataListe.length; j++) {
          _control.addList(
              dataListe[j]["Image URL"],
              dataListe[j]["Title"],
              dataListe[j]["Subtitle"],
              dataListe[j]["Salary"].toString(),
              dataListe[j]["jobs_id"],
              dataListe[j]["Description"],
              dataListe[j]["Location"],
              dataListe[j]["job_type"]);
        }
      } else if (dropdownValue_name == "Title") {
// Sort by Title
        dataListe.sort((a, b) => a["Title"].compareTo(b["Title"]));
        if (dropdownValue_order) {
          dataListe = dataListe.reversed.toList();
        }
        for (int j = 0; j < dataListe.length; j++) {
          _control.addList(
              dataListe[j]["Image URL"],
              dataListe[j]["Title"],
              dataListe[j]["Subtitle"],
              dataListe[j]["Salary"].toString(),
              dataListe[j]["jobs_id"],
              dataListe[j]["Description"],
              dataListe[j]["Location"],
              dataListe[j]["job_type"]);
        }
      }
      print(dataListe.length);
      //print(dataListe);
      print('Veri Çekildi');
      // You can use the data in the dataList here
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
            radius: 35,
            backgroundImage: AssetImage("lib/images/icon.png"),
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            "Jobify",
            style: TextStyle(
                fontSize: 40,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                color: const Color.fromARGB(255, 70, 96, 200)),
          ),
          Spacer(),
          /*ListTile(
            leading: Icon(Icons.home_outlined, color: KColors.primary),
            title: Text("HomePage"),
          ),*/
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: KColors.primary),
                Text(
                  "Home",
                  style: TextStyle(color: KColors.primary),
                )
              ],
            ),
          ),
          TextButton(
            child: Row(
              children: [
                Icon(Icons.bookmark_border_rounded, color: KColors.icon),
                Text(
                  "Saved Jobs",
                  style: TextStyle(color: KColors.subtitle),
                )
              ],
            ),
            onPressed: () {
              setState(() {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SavedJobs()));
              });
            },
          ),
          TextButton(
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded, color: KColors.icon),
                Text(
                  "Profile",
                  style: TextStyle(color: KColors.subtitle),
                )
              ],
            ),
            onPressed: () {
              Get.to(UserProfilePage());
            },
          ),
          TextButton(
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, color: KColors.icon),
                Text(
                  "Job Panel",
                  style: TextStyle(color: KColors.subtitle),
                )
              ],
            ),
            onPressed: () {
              Get.to(AdsPanel());
            },
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

  Widget _recommendedJob(
    BuildContext context, {
    required String img,
    required String company,
    required String title,
    required String sub,
    required String id,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          Get.to(JobDetailPage(), arguments: id);
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
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : KColors.lightGrey,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Image.asset(img),
                ),
                SizedBox(height: 6),
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

  Widget _header(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello",
              style: TextStyle(
                fontSize: 25,
                color: KColors.subtitle,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 6,
          ),
          Text("Find your perfect job",
              style: TextStyle(
                  fontSize: 35,
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
                        SearchBarr() /* Text(
                    "What are you looking for?",
                    style: TextStyle(fontSize: 15, color: KColors.subtitle),
                  ),*/
                    ),
              ),
              SizedBox(
                width: 16,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _recommendedSection(BuildContext context) {
    bool _remoteSelected = true;
    bool _faceToFaceSelected = false;
    bool _hybridSelected = false;
    const List<String> orderlist = <String>['ascending', 'descending'];
    const List<String> namelist = <String>[
      'Name',
      'Salary',
    ];

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 12),
        height: 600,
        //width: MediaQuery.of(context).size.width,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  dropdownbutton(orderlist),
                  SizedBox(
                    height: 8,
                  ),
                  dropdownbutton(namelist),
                  SizedBox(
                    height: 8,
                  ),
                  CheckboxListTile(
                    activeColor: KColors.primary,
                    title: Text('Remote'),
                    value: _controller.getCheck("remote"),
                    onChanged: (value) async {
                      setState(() {
                        _remoteSelected = value!;
                        if (_remoteSelected) {
                          _faceToFaceSelected = false;
                          _hybridSelected = false;
                        }
                        _controller.changeCheck(_remoteSelected,
                            _faceToFaceSelected, _hybridSelected);
                      });
                      _controller.list.clear();
                      await GetDatas();
                    },
                  ),
                  CheckboxListTile(
                    activeColor: KColors.primary,
                    title: Text('Face to Face'),
                    value: _controller.getCheck("face"),
                    onChanged: (value) async {
                      setState(() {
                        _faceToFaceSelected = value!;
                        if (_faceToFaceSelected) {
                          _remoteSelected = false;
                          _hybridSelected = false;
                        }
                        _controller.changeCheck(_remoteSelected,
                            _faceToFaceSelected, _hybridSelected);
                      });
                      _controller.list.clear();
                      await GetDatas();
                    },
                  ),
                  CheckboxListTile(
                      activeColor: KColors.primary,
                      title: Text('Hybrid'),
                      value: _controller.getCheck("hybrid"),
                      onChanged: (value) async {
                        setState(() {
                          _hybridSelected = value!;
                          if (_hybridSelected) {
                            _remoteSelected = false;
                            _faceToFaceSelected = false;
                          }
                          _controller.changeCheck(_remoteSelected,
                              _faceToFaceSelected, _hybridSelected);
                        });
                        _controller.list.clear();
                        await GetDatas();
                        print(value);
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentPostedJob(BuildContext context) {
    /*const List<String> orderlist = <String>['ascending', 'descending'];
    const List<String> namelist = <String>[
      'Name',
      'Salary',
    ];*/
    /*List<Widget> recentJobList = [
      _recommendedJob(context,
          img: Images.gitlab,
          title: "Gitlab",
          company: "UX Designer",
          sub: "\$78,000",
          id: "1"),
          
    ];
    recentJobglobal = recentJobList;*/
    return Container(
      width: 100,
      margin: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 200),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //SizedBox(height: 8,),
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
      backgroundColor: KColors.background,
      //bottomNavigationBar: BottomMenuBar(),
      body: Container(
        //width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appBar(context),
              _header(context),
              Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: _recommendedSection(context)),
                  Expanded(flex: 3, child: _recentPostedJob(context))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
