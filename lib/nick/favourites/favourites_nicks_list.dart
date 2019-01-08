import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:wear_hint/nick/nick_state.dart';

class FavouritesNicksListViewModel {
  final List<String> favouritesNicks;

  FavouritesNicksListViewModel.fromStore(Store<NickListState> store)
      : favouritesNicks = store.state.saved;
}

class FavouritesNicksList extends StatelessWidget {
  static const routeName = '/favourites';

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('The Best Nicks'),
        ),
        body: StoreConnector<NickListState, FavouritesNicksListViewModel>(
          converter: (store) => FavouritesNicksListViewModel.fromStore(store),
          builder: (context, viewModel) => _buildContent(context, viewModel),
        ));
  }

  _buildContent(BuildContext context, FavouritesNicksListViewModel viewModel) {
    final Iterable<ListTile> tiles = viewModel.favouritesNicks.map(
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
