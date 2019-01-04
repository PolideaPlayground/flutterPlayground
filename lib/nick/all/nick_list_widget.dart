import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:wear_hint/nick/all/presenter/nick_list_presenter.dart';
import 'package:wear_hint/nick/all/view/nick_list_view_contract.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';

class NickList extends StatefulWidget {
  @override
  NickListState createState() => NickListState();
}

class NickListStateModel {
  final List<String> nickNames;
  final List<String> saved;

  NickListStateModel.empty()
      : this.nickNames = <String>[],
        this.saved = <String>[];

  NickListStateModel(this.nickNames, this.saved);
}

class NickListState extends State<NickList> {
  NickListPresenterContract _presenter;
  NickListViewContract _view;
  NickListStateModel _model = NickListStateModel.empty();

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
    print("After fetch model there are  ${_model.nickNames.length} items");
    _view = NickListView(_presenter);
  }

  @override
  Widget build(BuildContext context) {
    print("build list  for ${_model.nickNames.length} items");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Nick Name Generator'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _view.buildContent(_model.nickNames, _model.saved),
    );
  }

  void _pushSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavouritesNicksList()),
    );
  }
}
