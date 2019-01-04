import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/all/repository/nick_repository.dart';

abstract class NickListPresenterContract {
  void loadNextPage();

  NickListStateModel fetchModel();

  void toggle(String nickName);
}

class NickListPresenter extends NickListPresenterContract {
  NickListState _state;
  final NickRepository _nickRepository = NickRepository();

  NickListPresenter(this._state) {
    _nickRepository.loadNextPage();
  }

  @override
  void loadNextPage() {
    _nickRepository.loadNextPage();
    _state.updateState(
        () => NickListStateModel(_nickRepository.all, _nickRepository.liked));
  }

  @override
  NickListStateModel fetchModel() {
    return NickListStateModel(_nickRepository.all, _nickRepository.liked);
  }

  @override
  void toggle(String nickName) {
    if (_nickRepository.liked.contains(nickName)) {
      _nickRepository.unlike(nickName);
    } else {
      _nickRepository.like(nickName);
    }
    _state.updateState(
        () => NickListStateModel(_nickRepository.all, _nickRepository.liked));
  }
}
