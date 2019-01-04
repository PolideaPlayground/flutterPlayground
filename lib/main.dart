import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:wear_hint/nick/all/nick_list_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: NickList(),
    );
  }
}
