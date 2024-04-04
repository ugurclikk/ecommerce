import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import '../theme/images.dart';
import '../ui/home_page.dart';
import '../ui/job_detail_page.dart';
import 'package:get/get.dart';

class RecentModel extends GetxController {
  var list = [
    _jobCard(
        img: Images.gitlab,
        title: "Gitlab",
        subtitle: "UX Designer",
        salery: "\$78,000"),
  ].obs; 

  void addList() {
   
    list.add(
      _jobCard(
          img: Images.gitlab,
          title: "Gitla",
          subtitle: "UX Designer",
          salery: "\$78,000"),
    );
    update(); // Trigger UI update if bound to widgets
  }

  int listlengt() {
 
    update();
    return list.length;
  }
}

Widget _jobCard({
  required String img,
  required String title,
  required String subtitle,
  required String salery,
}) {
  return InkWell(
    onTap: () {
      Get.to(JobDetailPage());
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
