
import 'package:esie/api/category.dart';
import 'package:esie/api/post.dart';
import 'package:esie/models/category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LevelFilter extends StatelessWidget {

  final List<Category> categories;

  final ValueChanged onChanged;

  LevelFilter({this.categories, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BaseDropdownButton(
      items: this.categories
          .map((Category category) {
            return DropdownMenuItem(child: Text(category.name), value: category.id);
          })
          .toList(),
      onChanged: onChanged,
    );
  }
}

class SortOptionsDropdownButton extends StatelessWidget {

  final ValueChanged onChanged;

  const SortOptionsDropdownButton({this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BaseDropdownButton(
      items: [
        DropdownMenuItem(child: Text("Newest first"), value: SortedBy.desc,),
        DropdownMenuItem(child: Text("Oldest first"), value: SortedBy.asc,),
      ],
      onChanged: onChanged
    ,);
  }
}

class TopFilters extends StatelessWidget {

  final _client = http.Client();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: fetchCategories(_client),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        if (! snapshot.hasData) {
          return Center(child: LinearProgressIndicator());
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            LevelFilter(categories: snapshot.data,),
            SortOptionsDropdownButton(onChanged: (value) {
              print(value);
              this.build(context);
              fetchCategories(_client);
            },)
          ],);
      },
    );
  }
}

class DropdownButtonState extends State {

  final List<DropdownMenuItem> items;

  final Text hint;

  dynamic _selected;

  final ValueChanged onChanged;

  DropdownButtonState({this.items, this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: this.items,
      value: this._selected,
      onChanged: (value) {
        setState(() {
          _selected = value;
        });

        this.onChanged(value);
      },
      hint: this.hint != null ? this.hint : (this.items.length > 0 ? this.items.first.child : null),
    );
  }
}

class BaseDropdownButton extends StatefulWidget {

  final List<DropdownMenuItem> items;

  final Text hint;

  final ValueChanged onChanged;

  BaseDropdownButton({this.items, this.hint, this.onChanged});

  @override
  State<StatefulWidget> createState() {
    return DropdownButtonState(items: items, hint: hint, onChanged: onChanged);
  }
}