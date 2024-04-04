import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import '../theme/images.dart';
import '../ui/home_page.dart';
import '../ui/job_detail_page.dart';
import 'package:get/get.dart';

class RecentModel extends GetxController {
  var list = [].obs; // Initialize list as an empty observable list

  void counter(BuildContext context) {
    // Clear the list
    list[0] = _recommendedJob(context,
        img: Images.dropbox,
        title: "Dropbox",
        company: "UX Designer",
        sub: "\$95,000",
        isSaved: false); // Add new items to the list

    update(); // Trigger UI update if bound to widgets
  }
}

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
