import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:wear_hint/nick/presenter/nick_list_presenter.dart';
import 'package:wear_hint/nick/view/nick_list_view_contract.dart';

class NickList extends StatefulWidget {
  @override
  NickListState createState() => NickListState();
}

class NickListStateModel {
  final List<String> suggestions;

  NickListStateModel() : this.suggestions = <String>[];

  NickListStateModel.withSuggestions(this.suggestions);
}

class NickListState extends State<NickList> {
  NickListPresenterContract _presenter;
  NickListViewContract _view;
  NickListStateModel _model = NickListStateModel();

  void updateState(NickListStateModel Function() createState) {
    setState(() {
      _model = createState();
    });
  }

  @override
  void initState() {
    print("init NickListState");
    super.initState();
    _presenter = NickListPresenter(this);
    print("fetch model from presenter");
    _model = _presenter.fetchModel();
    print("After fetch model there are  ${_model.suggestions.length} items");
    _view = NickListView(_presenter);
  }

  @override
  Widget build(BuildContext context) {
    print("build list  for ${_model.suggestions.length} items");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Nick Name Generator'),
//        actions: <Widget>[
//          // Add 3 lines from here...
//          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
//        ],
      ),
      body: _view.buildContent(_model.suggestions),
    );
  }
}
