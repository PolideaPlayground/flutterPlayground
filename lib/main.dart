import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_actions.dart';
import 'package:wear_hint/nick/nick_state.dart';
import 'package:wear_hint/nick/nick_reducer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Store<NickListState>(nickListReducer,
        initialState: NickListState.empty());
    store.dispatch(ReachedEndOfList());
    return StoreProvider<NickListState>(
      store: store,
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
