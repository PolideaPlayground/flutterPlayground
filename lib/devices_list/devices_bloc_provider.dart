import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';

class DevicesBlocProvider extends InheritedWidget {
  final DevicesBloc devicesBloc;

  DevicesBlocProvider({
    Key key,
    DevicesBloc devicesBloc,
    Widget child,
  })  : devicesBloc = devicesBloc ?? DevicesBloc(FlutterBlue.instance),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DevicesBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(DevicesBlocProvider)
              as DevicesBlocProvider)
          .devicesBloc;
}
