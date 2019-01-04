import 'package:english_words/english_words.dart';

class NickRepository {
  final _suggestions = <String>[];

  List<String> fetch() {
    if (_suggestions.isEmpty) {
      loadNextPage();
    }
    return _suggestions;
  }

  void loadNextPage() {
    _suggestions.addAll(
        generateWordPairs().take(10).map((wordPair) => wordPair.asPascalCase));
  }
}
