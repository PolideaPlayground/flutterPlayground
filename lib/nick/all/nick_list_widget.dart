import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_actions.dart';
import 'package:wear_hint/nick/nick_state.dart';

typedef void OnTap(String);

class NickListViewModel {
  final List<String> nickNames;
  final List<String> saved;
  final VoidCallback endOfListReached;
  final OnTap onTap;

  NickListViewModel.fromStore(Store<NickListState> store)
      : nickNames = store.state.nickNames,
        saved = store.state.saved,
        endOfListReached = (() => store.dispatch(ReachedEndOfList())),
        onTap = ((nickName) => store.dispatch(ToggleNickAction(nickName)));
}

class NickList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    print('Build NickList');
    print("Add scroll listener");
    return new Scaffold(
        appBar: AppBar(
          title: Text('Nick Name Generator'),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => _pushSaved(context)),
          ],
        ),
        body: StoreConnector<NickListState, NickListViewModel>(
          converter: (store) => NickListViewModel.fromStore(store),
          builder: (context, viewModel) => buildContent(viewModel),
        ));
  }

  void _pushSaved(BuildContext context) {
    Navigator.of(context).pushNamed(FavouritesNicksList.routeName);
  }

  @override
  Widget buildContent(NickListViewModel viewModel) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      print(
          "screen controller: ${scrollController.position.pixels}==${scrollController.position.maxScrollExtent}");
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print("observer list end");
        viewModel.endOfListReached();
      }
    });
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: scrollController,
        itemCount: 2 * viewModel.nickNames.length,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final nickName = viewModel.nickNames[i ~/ 2];
          final isLiked = viewModel.saved.contains(nickName);
          return _buildRow(nickName, isLiked, viewModel.onTap);
        });
  }

  Widget _buildRow(String nickName, bool isLiked, OnTap onTap) {
    return ListTile(
        title: Text(
          nickName,
          style: _biggerFont,
        ),
        trailing: new Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
        ),
        onTap: () => onTap(nickName));
  }
}
