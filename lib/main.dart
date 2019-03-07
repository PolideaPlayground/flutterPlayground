import 'package:flutter/material.dart';
import 'package:wear_hint/device_details/device_details_view.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/devices_list/devices_bloc_provider.dart';
import 'package:wear_hint/devices_list/devices_list_view.dart';
import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_provider.dart';

void main() {
  DevicesBloc devicesBloc = DevicesBloc();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NicksProvider(
      child: MaterialApp(
        title: 'Weather station',
        initialRoute: "/",
        routes: <String, WidgetBuilder>{
          "/": (context) => DevicesBlocProvider(child: DevicesListScreen()),
          "/details": (context) => DeviceDetailsView(),
        },
      ),
    );
  }
}
