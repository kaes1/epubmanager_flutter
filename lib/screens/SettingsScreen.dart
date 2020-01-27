import 'package:flutter/material.dart';
import 'package:epubmanager_flutter/services/StateService.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';
import 'MenuDrawer.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  final StateService _stateService = GetIt.instance.get<StateService>();

  final _serverAddressController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _stateService.getServerAddress().listen((serverAddress) => setState(() {
          log('In SettingsScreen listen!');
          _serverAddressController.text = serverAddress;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Server address'),
              subtitle: Text(_serverAddressController.text.isEmpty
                  ? 'No server address specified!'
                  : _serverAddressController.text),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Change server address'),
                        content: TextFormField(
                            controller: _serverAddressController,
                            decoration:
                                InputDecoration(hintText: "Server address...")),
                        actions: <Widget>[
                          new RaisedButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          new RaisedButton(
                              child: Text('Save'),
                              onPressed: () {
                                _saveServerAddress();
                                Navigator.of(context).pop();
                              })
                        ],
                      );
                    });
              },
            )
          ],
        ),
      ),
    );
  }

  void _saveServerAddress() {
    _stateService.setServerAddress(_serverAddressController.text);
  }
}
