import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import '../theme/images.dart';
import '../ui/home_page.dart';
import '../ui/job_detail_page.dart';
import 'package:get/get.dart';

class RecentModel extends GetxController {
  var list = [].obs;

  void addList(
      String img, String title, String subtitle, String salery, String id) {
    list.add(
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
}

Widget _jobCard({
  required String img,
  required String title,
  required String subtitle,
  required String salery,
  required String id,
}) {
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
            child: Image.network(img),
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
