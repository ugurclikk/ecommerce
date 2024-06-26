import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import '../theme/images.dart';
import '../ui/home_page.dart';
import '../ui/job_detail_page.dart';
import 'package:get/get.dart';

class RecentModel extends GetxController {
  var list = [].obs;
  var savedlist = [].obs;
  var selectList = [].obs;
  RecentModel() {
    bool _remoteSelected = false;
    bool _faceToFaceSelected = false;
    bool _hybridSelected = false;
    selectList.add(_remoteSelected);
    selectList.add(_faceToFaceSelected);
    selectList.add(_hybridSelected);
  }
  bool getCheck(var value) {
    switch (value) {
      case "remote":
        return selectList[0];
      case "face":
        return selectList[1];
      case "hybrid":
        return selectList[2];
      default:
        return false;
    }
  }

  void changeCheck(var remote,var face,var hybrid) {
    selectList[0]=remote;
    selectList[1]=face;
    selectList[2]=hybrid;
    update();
  }

  void addList(
    String img,
    String title,
    String subtitle,
    String salery,
    String id,
    String desc,
     String loc,
    String type,
  ) {
    list.add(
      _recommendedJob(
        location: loc,
        type: type,
        desc: desc,
        company: title,
        img: img,
        title: title,
        sub: subtitle,
        isActive: false,
        id: id,
      ),
    );
    update(); // Trigger UI update if bound to widgets
  }

  void addSavedList(
      String img, String title, String subtitle, String salery, String id) {
    savedlist.add(
      _jobCard(
        img: img,
        title: title,
        subtitle: subtitle,
        salery: salery,
        id: id,
      ),
    );
    update(); // Trigger UI update if bound to widgets
  }

  int listlengt() {
    update();
    return list.length;
  }

  int listsavedlengt() {
    update();
    return savedlist.length;
  }

  void clearlist() {
    list.clear();
    update();
  }
}

Widget _jobCard({
  required String img,
  required String title,
  required String subtitle,
  required String salery,
  required String id,
}) {
  String title1 = title;
  return InkWell(
    onTap: () {
      Get.to(JobDetailPage(), arguments: id);
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
            child: Image.network(
              img,
              scale: 5.0,
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: KColors.subtitle,
                ),
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

Widget _recommendedJob({
  required String img,
  required String company,
  required String title,
  required String sub,
  required String id,
   required String location,
  required String type,
  required String desc,
  bool isActive = false,
}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: InkWell(
      onTap: () {
        Get.to(JobDetailPage(), arguments: id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? KColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(7),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : KColors.lightGrey,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Image.network(img),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                    SizedBox(height: 6),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.white38 : KColors.subtitle,
                      ),
                    ),
                     SizedBox(height: 6),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.white38 : KColors.subtitle,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
