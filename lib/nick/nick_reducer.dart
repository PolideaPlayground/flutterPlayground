import 'package:wear_hint/nick/all/repository/nick_repository.dart';
import 'package:wear_hint/nick/nick_actions.dart';
import 'package:wear_hint/nick/nick_state.dart';

final NickRepository _nickRepository = NickRepository();

NickListState nickListReducer(NickListState state, dynamic action) {
  if (action is ReachedEndOfList) {
    _nickRepository.loadNextPage();
    return NickListState.clone(state)
      ..nickNames.clear()
      ..nickNames.addAll(_nickRepository.all);
  }

  if (action is ToggleNickAction) {
    if (_nickRepository.liked.contains(action.nickName)) {
      _nickRepository.unlike(action.nickName);
    } else {
      _nickRepository.like(action.nickName);
    }
    return NickListState.clone(state)
      ..saved.clear()
      ..saved.addAll(_nickRepository.liked);
  }
  return state;
}
