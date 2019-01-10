import 'package:flutter/material.dart';
import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NicksProvider(
      child: MaterialApp(
        title: 'Welcome to Flutter',
        home: NickList(),
        routes: <String, WidgetBuilder>{
          FavouritesNicksList.routeName: (context) => FavouritesNicksList(),
        },
      ),
    );
  }
}
