import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditAdPage extends StatefulWidget {
  final String userId;
  final String adId;
  final Map<String, dynamic> adData;

  const EditAdPage(
      {Key? key,
      required this.userId,
      required this.adId,
      required this.adData})
      : super(key: key);

  @override
  _EditAdPageState createState() => _EditAdPageState();
}

class _EditAdPageState extends State<EditAdPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _SalaryController;
  late TextEditingController _SubtitleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.adData['Title']);
    _descriptionController =
        TextEditingController(text: widget.adData['Description']);
    _SalaryController = TextEditingController(text: widget.adData['Salary'].toString());
    _SubtitleController =
        TextEditingController(text: widget.adData['Subtitle']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Ad'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _SubtitleController,
              decoration: InputDecoration(labelText: 'SubTitle'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _SalaryController,
              decoration: InputDecoration(labelText: 'Salary'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // Save changes to Firestore and then navigate back
    String newTitle = _titleController.text;
    String newDescription = _descriptionController.text;
    String salary = _SalaryController.text;
    String subtitle = _SubtitleController.text;
    print(widget.userId+" "+ widget.adId);
    // Update Firestore document with new data
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('added_jobs')
        .doc(widget.adId)
        .update({
      'Title': newTitle,
      'Description': newDescription,
      'SubTitle': subtitle,
      'Salary': int.parse(salary),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ad details updated successfully')),
      );
      Navigator.pop(context); // Navigate back
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ad details')),
      );
    });
  }
}
