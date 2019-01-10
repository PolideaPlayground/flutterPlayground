import 'dart:async';

import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/all/repository/nick_repository.dart';
import 'package:wear_hint/nick/model/nicks.dart';
import 'package:rxdart/subjects.dart';

class NeedMoreNicks {}

class NickBloc {
  final Nicks _nicksModel = Nicks.empty();
  static final NickRepository _nickRepository = NickRepository();

  final BehaviorSubject<NickListViewModel> _nicks =
      BehaviorSubject<NickListViewModel>(
          seedValue: NickListViewModel(<String>[], <String>[]));

  final StreamController<NeedMoreNicks> _needMoreNicksController =
      StreamController<NeedMoreNicks>();

  final StreamController<String> _favouritesController =
      StreamController<String>();

  Sink<NeedMoreNicks> get needMoreNicks => _needMoreNicksController.sink;

  Stream<NickListViewModel> get nicks => _nicks.stream;

  Sink<String> get favouritesToggle => _favouritesController.sink;

  final BehaviorSubject<List<String>> _favourites =
      BehaviorSubject<List<String>>(seedValue: _nickRepository.liked);
  Stream<List<String>> get favourites => _favourites.stream;

  NickBloc() {
    _needMoreNicksController.stream.listen((needMoreNicks) {
      _nickRepository.loadNextPage();
      _nicksModel.nickNames
        ..clear()
        ..addAll(_nickRepository.all);
      _nicks.add(NickListViewModel(_nicksModel.nickNames, _nicksModel.saved));
    });

    _favouritesController.stream.listen((nick) {
      if (_nickRepository.liked.contains(nick)) {
        _nickRepository.unlike(nick);
      } else {
        _nickRepository.like(nick);
      }
      _nicksModel.saved
        ..clear()
        ..addAll(_nickRepository.liked);
      _nicks.add(NickListViewModel(_nicksModel.nickNames, _nicksModel.saved));
    });
  }

  void dispose() {
    _nicks.close();
    _needMoreNicksController.close();
    _favouritesController.close();
    _favourites.close();
  }
}
