import 'package:flutter/material.dart';
import 'package:wear_hint/nick/all/presenter/nick_list_presenter.dart';

abstract class NickListViewContract {
  Widget buildContent(List<String> nickNames, List<String> saved);
}

class NickListView extends NickListViewContract {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  NickListPresenterContract _presenter;
  final ScrollController _scrollController = ScrollController();

  NickListView(this._presenter) {
    print("Add scroll listener");
    _scrollController.addListener(() {
      print(
          "screen controller: ${_scrollController.position.pixels}==${_scrollController.position.maxScrollExtent}");
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("observer list end");
        _presenter.loadNextPage();
      }
    });
  }

  @override
  Widget buildContent(List<String> nickNames, List<String> liked) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        itemCount: 2 * nickNames.length,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final nickName = nickNames[i ~/ 2];
          final isLiked = liked.contains(nickName);
          return _buildRow(nickName, isLiked);
        });
  }

  Widget _buildRow(String nickName, bool isLiked) {
    return ListTile(
      title: Text(
        nickName,
        style: _biggerFont,
      ),
      trailing: new Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : null,
      ),
      onTap: () {
        _presenter.toggle(nickName);
      },
    );
  }
}
