import 'dart:developer';
import 'dart:io';

import 'package:epub/epub.dart';
import 'package:epubmanager_flutter/book/BookService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/NewBook.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../MenuDrawer.dart';

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
  }

  String _filePath;
  EpubMetadata _epubMetadata;

  List<String> _selectedTags = [];

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
      body: Center(
        child: Card(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _clearSelection();
                  _pickEpubFile();
                },
                child: Text('CHOOSE'),
              ),
              if (_loading) CircularProgressIndicator(),
              if (_epubMetadata != null)
                Column(
                  children: <Widget>[
                    Divider(),
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
              Divider(),
              if (_errorMessage != null)
                Text(_errorMessage, style: TextStyle(color: Colors.red)),
              if (_errorMessage != null) Divider(),
              RaisedButton(
                  child: Text('ADD'),
                  onPressed:
                      (_epubMetadata != null && _alreadyExistingBook == null)
                          ? () => _addBook()
                          : null)
            ],
          ),
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _filePath = null;
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
      _loading = true;
    });
    log('Picked $_filePath');

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
