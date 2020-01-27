import 'dart:developer';
import 'dart:io';

import 'package:epub/epub.dart';
import 'package:epubmanager_flutter/services/BookService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/NewBook.dart';
import 'package:epubmanager_flutter/model/Tag.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:get_it/get_it.dart';

import 'MenuDrawer.dart';

class BookUploadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookUploadScreenState();
  }
}

class BookUploadScreenState extends State<BookUploadScreen> {
  final BookService _bookService = GetIt.instance.get<BookService>();

  @override
  void initState() {
    super.initState();
    this._getAllTags();
  }

  List<Tag> _allTags = [];
  List<String> _selectedTags = [];
  List<dynamic> _multiSelectValue = null;

  String _fileName = '...';
  String _filePath;
  EpubMetadata _epubMetadata;

  Book _alreadyExistingBook;

  String _errorMessage;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('Upload .epub'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 24),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 400,
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 2,
                      readOnly: true,
                      onTap: (){
                        _clearSelection();
                        _pickEpubFile();
                      },
                      decoration: new InputDecoration(
                        prefixIcon:  Icon(
                          Icons.file_upload,
                          color: Colors.deepPurple,
                        ),
                        hintText: _fileName,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                        ),
                        //fillColor: Colors.green
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  if (_loading) CircularProgressIndicator(),
                  if (_epubMetadata != null)
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: <Widget>[
                          Text('Title: ' + _epubMetadata.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16)),
                          Text('Author: ' + _epubMetadata.author,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16)),
                          Text('Publisher: ' + (_epubMetadata.publisher ?? '-'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16)),
                          Text('Language: ' + (_epubMetadata.language ?? '-'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 15.0,
                  ),
                  if (_epubMetadata != null && _errorMessage == null)
                    Flexible(
                      child: SingleChildScrollView(
                        child: MultiSelect(
                          autovalidate: false,
                          titleText: 'Tags: ',
                          validator: (value) {
                            if (value == null) {
                              return 'Please select tag(s)';
                            } else return null;
                          },
                          errorText: 'Please select tag(s)',
                          dataSource: this._allTags.map((tag) {
                            return {'name': tag.name, 'id': tag.name};
                          }).toList(),
                          textField: 'name',
                          valueField: 'id',
                          filterable: false,
                          required: false,
                          initialValue: this._multiSelectValue,
                          value: null,
                          change: (value) {
                            setState(() {
                              this._multiSelectValue = value;
                              if(value != null) {
                                this._selectedTags = List(value.length);
                                for (int i = 0; i < value.length; i++) {
                                  this._selectedTags[i] = value[i];
                                }
                              } else {
                                this._selectedTags = [];
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  if (_errorMessage != null)
                    Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  if(_alreadyExistingBook != null && _errorMessage != null)
                    SizedBox(
                      height: 15.0,
                    ),
                  if(_alreadyExistingBook != null && _errorMessage != null)
                    InkWell(
                      splashColor: Colors.grey,
                      child: Text(
                        'Go to book details',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(_alreadyExistingBook.id)));
                      },
                    ),
                  SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    width: 250,
                    child:Row(
                      children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                                child: Text('ADD'),
                                color: Colors.deepPurple,
                                textColor: Colors.white,
                                onPressed:
                                (_epubMetadata != null && _alreadyExistingBook == null)
                                    ? () => _addBook()
                                    : null)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _filePath = null;
      _fileName = '...';
      _alreadyExistingBook = null;
      _epubMetadata = null;
      _errorMessage = null;
      _loading = false;
    });
  }

  void _pickEpubFile() async {
    _filePath = await FilePicker.getFilePath(
        type: FileType.CUSTOM, fileExtension: 'epub');

    setState(() {
      if(_filePath == null){
        _loading = false;
        _errorMessage = 'EPUB file is not selected';
        _fileName = '...';
      } else {
        _loading = true;
        _fileName = _filePath.split('/').last;
      }
    });
    log('Picked $_filePath');

    if(_filePath != null) {
      List<int> bytes = await new File(_filePath).readAsBytes();

      try {
        EpubBook epubBook = await EpubReader.readBook(bytes);
        EpubMetadata epubMetadata = _retrieveMetadata(epubBook);
        _fetchBookIfExists(epubMetadata);
        setState(() {
          _epubMetadata = epubMetadata;
        });
      } on EpubParsingException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } on Exception {
        setState(() {
          _errorMessage = 'EPUB file is invalid.';
        });
      }
    }
    setState(() {
      _loading = false;
    });
  }

  EpubMetadata _retrieveMetadata(EpubBook epubBook) {
    var metadata = epubBook.Schema.Package.Metadata;
    String title;
    String author;
    if (metadata.Titles.isNotEmpty && metadata.Titles[0].isNotEmpty) {
      title = metadata.Titles[0];
    } else {
      throw new EpubParsingException('E-book contains no title metadata.');
    }
    if (metadata.Creators.isNotEmpty &&
        metadata.Creators[0].Creator.isNotEmpty) {
      author = metadata.Creators[0].Creator;
    } else {
      throw new EpubParsingException('E-book contains no author metadata.');
    }
    String language =
    metadata.Languages.isNotEmpty ? metadata.Languages[0] : null;
    String publisher =
    metadata.Publishers.isNotEmpty ? metadata.Publishers[0] : null;
    return new EpubMetadata(title, author, publisher, language);
  }

  void _addBook() {
    NewBook newBook = new NewBook(_epubMetadata.title, _epubMetadata.author,
        _epubMetadata.publisher, _epubMetadata.language, _selectedTags);
    _bookService.addBook(newBook).then((book) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => BookDetailsScreen(book.id)));
    });
  }

  void _fetchBookIfExists(EpubMetadata epubMetadata) {
    _bookService
        .findExactBook(epubMetadata.title, epubMetadata.author)
        .then((response) {
      setState(() {
        _alreadyExistingBook = response;
        _errorMessage = 'Book already added!';
      });
    }).catchError((error) {
      //Book doesn't exist
    });
  }

  void _getAllTags() {
    _bookService.getAllTags().then((allTags){
      setState(() {
        allTags.sort((t1, t2) {
          return t1.name.compareTo(t2.name);
        });
        this._allTags = allTags;
      });
    });
  }
}

class EpubMetadata {
  String title;
  String author;
  String publisher;
  String language;

  EpubMetadata(this.title, this.author, this.publisher, this.language);
}

class EpubParsingException implements Exception {
  String message;

  EpubParsingException(this.message);
}
