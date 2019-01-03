import 'package:english_words/english_words.dart';

class NickRepository {
  final _suggestions = <WordPair>[];

  List<WordPair> fetch() {
    if (_suggestions.isEmpty) {
      _loadNextPage();
    }
    return _suggestions;
  }

  void _loadNextPage() {
    _suggestions.addAll(generateWordPairs().take(10));
  }
}
