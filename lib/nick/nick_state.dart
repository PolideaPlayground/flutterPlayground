class NickListState {
  final List<String> nickNames;
  final List<String> saved;

  NickListState.empty()
      : this.nickNames = <String>[],
        this.saved = <String>[];

  NickListState.clone(NickListState nickListState)
      : nickNames = List.from(nickListState.nickNames),
        saved = List.from(nickListState.saved);

  NickListState(this.nickNames, this.saved);
}
