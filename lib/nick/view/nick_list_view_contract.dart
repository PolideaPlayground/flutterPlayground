import 'package:flutter/material.dart';
import 'package:wear_hint/nick/presenter/nick_list_presenter.dart';

abstract class NickListViewContract {
  Widget buildContent(List<String> nickNames);
}

class NickListView extends NickListViewContract {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  NickListPresenterContract _presenter;
  final ScrollController _scrollController = ScrollController();

  NickListView(this._presenter) {
    print("Add scroll listener");
    _scrollController.addListener(() {
      print(
          "screen controller: ${_scrollController.position.pixels}==${_scrollController.position.maxScrollExtent}");
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("observer list end");
        _presenter.loadNextPage();
      }
    });
  }

  @override
  Widget buildContent(List<String> nickNames) {
   ListTile.divideTiles(tiles: null)
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        itemCount: 2 * nickNames.length,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/
//
//          final index = i ~/ 2; /*3*/
//          if (index >= _suggestions.length) {
//            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//          }
//          return _buildRow(_suggestions[index]);
          return _buildRow(nickNames[(i / 2).floor()]);
        });
  }

  Widget _buildRow(String nickName) {
    return ListTile(
      title: Text(
        nickName,
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
