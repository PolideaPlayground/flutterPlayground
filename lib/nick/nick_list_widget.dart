import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:wear_hint/nick/presenter/nick_list_presenter.dart';
import 'package:wear_hint/nick/view/nick_list_view_contract.dart';

class NickList extends StatefulWidget {
  @override
  NickListState createState() => NickListState();
}

class NickListState extends State<NickList> {
  NickListPresenterContract _presenter;
  NickListViewContract _view;

  final _suggestions = <WordPair>[];

  @override
  void initState() {
    super.initState();
    _presenter = NickListPresenter(this);
    _view = NickListView(_presenter);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Nick Name Generator'),
//        actions: <Widget>[
//          // Add 3 lines from here...
//          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
//        ],
      ),
      body: _view.buildContent(),
    );
  }
}
