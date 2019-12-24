import 'package:flutter/material.dart';

import '../MenuDrawer.dart';

class BookDetailsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookDetailsScreenState();
  }
}

class BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(),
    );
  }
}
