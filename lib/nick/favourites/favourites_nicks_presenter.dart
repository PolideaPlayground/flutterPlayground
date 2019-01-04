import 'package:wear_hint/nick/all/repository/nick_repository.dart';

abstract class FavouritesNicksPresenter {
  List<String> fetchFavouritesNicks();
}

class FavouritesNicksPresenterImpl extends FavouritesNicksPresenter {
  final NickRepository _nickRepository = NickRepository();

  @override
  List<String> fetchFavouritesNicks() {
    return _nickRepository.liked;
  }
}
