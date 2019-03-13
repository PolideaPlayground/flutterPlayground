import 'package:flutter/material.dart';
import 'package:wear_hint/device_details/device_details_view.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/devices_list/devices_bloc_provider.dart';
import 'package:wear_hint/devices_list/devices_list_view.dart';
import 'package:wear_hint/nick/all/nick_list_widget.dart';
import 'package:wear_hint/nick/favourites/favourites_nicks_list.dart';
import 'package:wear_hint/nick/nick_provider.dart';
import 'package:fimber/fimber.dart';


void main() {
  Fimber.plantTree(DebugTree());
  runApp(MyApp());
}
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NicksProvider(
      child: MaterialApp(
        title: 'Weather station',
        theme: new ThemeData(
            primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        ),
        initialRoute: "/",
        routes: <String, WidgetBuilder>{
          "/": (context) => DevicesBlocProvider(child: DevicesListScreen()),
          "/details": (context) => DeviceDetailsView(),
          "/details2": (context) => DeviceDetailsView(),
        },
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
