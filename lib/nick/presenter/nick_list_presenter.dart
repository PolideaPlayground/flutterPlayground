import 'package:wear_hint/nick/nick_list_widget.dart';

abstract class NickListPresenterContract {
  String fetchNick(int index);
}

class NickListPresenter extends NickListPresenterContract {
  NickListState _state;

  NickListPresenter(this._state);

  @override
  String fetchNick(int index) {
    // TODO: implement fetchNick
    return null;
  }
}
