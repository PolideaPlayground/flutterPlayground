import 'package:english_words/english_words.dart';

class NickRepository {
  final _nicks = <String>[];
  final _liked = <String>[];

  List<String> get all => _nicks;

  List<String> get liked => _liked;

  static final NickRepository _nickRepository = NickRepository._internal();

  factory NickRepository() {
    return _nickRepository;
  }

  NickRepository._internal();

  void loadNextPage() {
    _nicks.addAll(
        generateWordPairs().take(10).map((wordPair) => wordPair.asPascalCase));
  }

  void like(String nickName) {
    _liked.add(nickName);
  }

  void unlike(String nickName) {
    _liked.remove(nickName);
  }
}
