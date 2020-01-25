import 'package:epubmanager_flutter/book/BookListService.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EditBookListDialog extends StatefulWidget {
  final int _bookId;
  final BookListEntry _existingEntry;

  final Function onClose;

  EditBookListDialog(this._bookId, this._existingEntry, {this.onClose});

  @override
  State<StatefulWidget> createState() {
    return EditBookListDialogState();
  }
}

class EditBookListDialogState extends State<EditBookListDialog> {
  final BookListService _bookListService =
      GetIt.instance.get<BookListService>();

  final _possibleRatings = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  final _possibleStatuses = ['COMPLETED', 'READING', 'PLAN_TO_READ']; //todo status to string method for pretty display

  int _selectedRating;
  String _selectedStatus;

  @override
  Widget build(BuildContext context) {

    if (widget._existingEntry != null) {
      this._selectedRating = widget._existingEntry.rating;
      this._selectedStatus = widget._existingEntry.status;
    }

    return AlertDialog(
      title: Text(
        'Add to list',
        textAlign: TextAlign.center,
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Status: '),
              DropdownButton(
                value: _selectedStatus,
                items: _possibleStatuses.map((status) {
                  return DropdownMenuItem(child: Text(status), value: status);
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                },
              ),
              Text('Your rating: '),
              DropdownButton(
                value: _selectedRating,
                items: _possibleRatings.map((rating) {
                  return DropdownMenuItem(
                      child: Text(rating.toString()), value: rating);
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRating = value);
                },
              ),
              SizedBox(
                height: 30.0,
              ),
              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: widget._existingEntry == null
                          ? new Text('ADD')
                          : new Text('EDIT'),
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      onPressed:
                          _selectedStatus == null ? null : _editBookListEntry,
                    ),
                  ),
                  if (widget._existingEntry != null) SizedBox(width: 10),
                  if (widget._existingEntry != null)
                    Expanded(
                      child: RaisedButton(
                        //TODO proper color design
                        child: new Text('DELETE'),
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed: _deleteBookListEntry,
                      ),
                    ),
                ],
              ),
              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: new Text('CANCEL'),
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  void _editBookListEntry() {
    _bookListService
        .editBookListEntry(widget._bookId, _selectedRating, _selectedStatus)
        .then((response) {
      widget.onClose();
      Navigator.of(context).pop();
    });
  }

  void _deleteBookListEntry() {
    _bookListService.deleteBookListEntry(widget._bookId).then((response) {
      widget.onClose();
      Navigator.of(context).pop();
    });
  }
}