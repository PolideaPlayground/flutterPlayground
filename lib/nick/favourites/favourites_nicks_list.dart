import 'package:flutter/material.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_presenter.dart';

class FavouritesNicksList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final presenter = FavouritesNicksPresenterImpl();
    final Iterable<ListTile> tiles = presenter.fetchFavouritesNicks().map(
      (String nick) {
        return new ListTile(
          title: new Text(
            nick,
            style: _biggerFont,
          ),
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('The Best Nicks'),
      ),
      body: ListView(children: divided),
    );
  }
}
