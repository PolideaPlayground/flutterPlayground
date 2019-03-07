import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/repository/device_repository.dart';

class DevicesBlocProvider extends InheritedWidget {
  final DevicesBloc devicesBloc;

  DevicesBlocProvider({
    Key key,
    DevicesBloc devicesBloc,
    Widget child,
  })  : devicesBloc = devicesBloc ?? DevicesBloc(FlutterBlue.instance, DeviceRepository()),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DevicesBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(DevicesBlocProvider)
              as DevicesBlocProvider)
          .devicesBloc;
}
