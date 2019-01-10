import 'package:flutter/material.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_bloc.dart';
import 'package:wear_hint/nick/nick_provider.dart';

typedef void OnTap(String nick);

class NickListViewModel {
  final List<String> nickNames;
  final List<String> saved;

  NickListViewModel(this.nickNames, this.saved);
}

class NickList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  NickBloc _nickBloc;

  @override
  Widget build(BuildContext context) {
    print('Build NickList');
    print("Add scroll listener");
    _nickBloc = NicksProvider.of(context);
    _needMoreNicks();
    return new Scaffold(
        appBar: AppBar(
          title: Text('Nick Name Generator'),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => _pushSaved(context)),
          ],
        ),
        body: StreamBuilder<NickListViewModel>(
          initialData: NickListViewModel(<String>[], <String>[]),
          stream: _nickBloc.nicks,
          builder: (context, snapshot) => buildContent(snapshot.data),
        ));
  }

  void _pushSaved(BuildContext context) {
    Navigator.of(context).pushNamed(FavouritesNicksList.routeName);
  }

  Widget buildContent(NickListViewModel viewModel) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print("observer list end");
        _needMoreNicks();
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
          return _buildRow(nickName, isLiked, null);
        });
  }

  Widget _buildRow(String nickName, bool isLiked, OnTap onTap) {
    print('Build row for $nickName -> $isLiked');
    return ListTile(
      title: Text(
        nickName,
        style: _biggerFont,
      ),
      trailing: new Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : null,
      ),
      onTap: () => _nickBloc.favouritesToggle.add(nickName),
    );
  }

  void _needMoreNicks() {
    _nickBloc.needMoreNicks.add(NeedMoreNicks());
  }
}
