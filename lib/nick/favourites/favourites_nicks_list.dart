import 'package:flutter/material.dart';
import 'package:wear_hint/nick/nick_bloc.dart';
import 'package:wear_hint/nick/nick_provider.dart';

class FavouritesNicksListViewModel {
  final List<String> favouritesNicks;

  FavouritesNicksListViewModel(this.favouritesNicks);
}

class FavouritesNicksList extends StatelessWidget {
  static const routeName = '/favourites';

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    NickBloc _nickBloc = NicksProvider.of(context);
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('The Best Nicks'),
        ),
        body: StreamBuilder<List<String>>(
            stream: _nickBloc.favourites,
            builder: (context, snapshot) =>
                _buildContent(context, snapshot.data)));
  }

  _buildContent(BuildContext context, List<String> favouritesNicks) {
    final Iterable<ListTile> tiles = favouritesNicks.map(
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

    return ListView(children: divided);
  }
}
