import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/home_page.dart';
import 'package:flutter_job_portal/ui/job_detail_page.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchBar({Key? key, this.onChanged, this.hintText = 'What are you looking for?'}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.hintText,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
