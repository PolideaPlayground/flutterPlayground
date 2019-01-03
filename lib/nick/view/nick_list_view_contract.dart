import 'package:flutter/material.dart';
import 'package:wear_hint/nick/presenter/nick_list_presenter.dart';

abstract class NickListViewContract {
  Widget buildContent();
}

class NickListView extends NickListViewContract {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  NickListPresenterContract _presenter;

  NickListView(this._presenter);

  @override
  Widget buildContent() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/
//
//          final index = i ~/ 2; /*3*/
//          if (index >= _suggestions.length) {
//            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//          }
//          return _buildRow(_suggestions[index]);
          return _buildRow();
        });
  }

  Widget _buildRow() {
    return ListTile(
      title: Text(
        "Kabumkabum",
        style: _biggerFont,
      ),
      trailing: new Icon(
          // Add the lines from here...
          Icons.favorite_border),
//      onTap: () {
//        setState(() {
//          if (alreadySaved) {
//            _saved.remove(pair);
//          } else {
//            _saved.add(pair);
//          }
//        });
//      },
    );
  }
}
