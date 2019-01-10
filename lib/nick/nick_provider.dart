import 'package:flutter/widgets.dart';
import 'package:wear_hint/nick/nick_bloc.dart';

class NicksProvider extends InheritedWidget {
  final NickBloc nickBloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  NicksProvider({
    Key key,
    NickBloc nickBloc,
    Widget child,
  })  : nickBloc = nickBloc ?? NickBloc(),
        super(key: key, child: child);

  static NickBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(NicksProvider) as NicksProvider)
          .nickBloc;
}
