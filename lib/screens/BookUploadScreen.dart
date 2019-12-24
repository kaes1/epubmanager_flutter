import 'package:flutter/material.dart';

import '../MenuDrawer.dart';

class BookUploadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookUploadScreenState();
  }
}

class BookUploadScreenState extends State<BookUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(title: Text('Upload .epub'),),
      body: Card(
        child: Text('Choose .epub file'),
      ),
    );
  }
}
