import 'package:wear_hint/nick/nick_list_widget.dart';
import 'package:wear_hint/nick/repository/nick_repository.dart';

abstract class NickListPresenterContract {
  void loadNextPage();

  NickListStateModel fetchModel();
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
        () => NickListStateModel.withSuggestions(_nickRepository.fetch()));
  }

  @override
  NickListStateModel fetchModel() {
    return NickListStateModel.withSuggestions(_nickRepository.fetch());
  }
}
