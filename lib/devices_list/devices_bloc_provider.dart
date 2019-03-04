import 'package:flutter/widgets.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';

class DevicesBlocProvider extends InheritedWidget {
  final DevicesBloc cartBloc;

  DevicesBlocProvider({
    Key key,
    DevicesBloc cartBloc,
    Widget child,
  })  : cartBloc = cartBloc ?? DevicesBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DevicesBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(DevicesBlocProvider)
              as DevicesBlocProvider)
          .cartBloc;
}
