import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/devices_list/devices_bloc_provider.dart';
import 'package:wear_hint/model/ble_device.dart';

typedef DeviceTapListener = void Function();

class DevicesListScreen extends StatefulWidget {

  @override
  State<DevicesListScreen> createState() {
    return DeviceListScreenState();
  }


}

class DeviceListScreenState extends State<DevicesListScreen> {

  DevicesBloc _devicesBloc;
  StreamSubscription _appStateSubscription;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("DeviceListScreenState didChangeDependencies");
    if (_devicesBloc == null) {
      _devicesBloc = DevicesBlocProvider.of(context);
      _devicesBloc.init();
      _appStateSubscription = _devicesBloc.applicationState.listen(
              (applicationState) {
                print("navigate to details");
                Navigator.pushNamed(context, "/details");
              }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build DeviceListScreenState");
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        title: Text('BLE devices'),
      ),
      body: StreamBuilder<List<BleDevice>>(
        initialData: _devicesBloc.visibleDevices.value,
        stream: _devicesBloc.visibleDevices,
        builder: (context, snapshot) =>
            DevicesList(_devicesBloc, snapshot.data),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _appStateSubscription.cancel();
    _devicesBloc.dispose();
  }
}

class DevicesList extends ListView {
  static final _biggerFont = const TextStyle(fontSize: 18.0);

  DevicesList(DevicesBloc devicesBloc, List<BleDevice> devices)
      : super.builder(
            padding: const EdgeInsets.all(16.0),
//            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, i) {
              print("Build row for $i");
              return _buildRow(
                  devices[i], _createTapListener(devicesBloc, devices[i]));
            });

  static DeviceTapListener _createTapListener(
      DevicesBloc devicesBloc, BleDevice bleDevice) {
    return () {
      print("clicked device: ${bleDevice.name}");
      devicesBloc.devicePicker.add(bleDevice);
    };
  }

  static Widget _buildRow(
      BleDevice device, DeviceTapListener deviceTapListener) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: ListTile(
          title: Text(device.name, style: _biggerFont),
          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 1.0, color: Colors.white24))),
            child: Icon(Icons.autorenew, color: Colors.white),
          ),
          onTap: deviceTapListener,
        ),
      ),
    );
  }
}
