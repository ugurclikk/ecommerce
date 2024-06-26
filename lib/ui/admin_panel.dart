import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'add_jobs.dart';
import 'edit_page.dart';

class AdsPanel extends StatefulWidget {
  @override
  _AdsPanelState createState() => _AdsPanelState();
}

class _AdsPanelState extends State<AdsPanel> {
  Future<void> _deleteAd(String userId, String adId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('added_jobs')
          .doc(adId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ad deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ad')),
      );
    }
  }

  Future<void> _editAd(
      String userId, String adId, Map<String, dynamic> adData) async {
    // Navigate to the edit ad page and pass necessary data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditAdPage(userId: userId, adId: adId, adData: adData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = "";
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Get.to(InputPage());
              },
              icon: Icon(Icons.add))
        ],
        title: Text('Ads Panel'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('added_jobs')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No ads found'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> adData =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(adData['Title']),
                subtitle: Text(adData['Description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editAd(userId, document.id, adData);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteAd(userId, document.id);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
