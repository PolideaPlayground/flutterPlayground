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
    _devicesBloc = DevicesBlocProvider.of(context);
    _devicesBloc.init();
    _appStateSubscription?.cancel();
    _appStateSubscription = _devicesBloc.applicationState.listen(
            (applicationState) => Navigator.pushNamed(context, "/details")
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    _devicesBloc.dispose();
  }
}

class DevicesList extends ListView {
  static final _biggerFont = const TextStyle(fontSize: 18.0);

  DevicesList(DevicesBloc devicesBloc, List<BleDevice> devices)
      : super.builder(
            padding: const EdgeInsets.all(16.0),
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
    return ListTile(
      title: Text(device.name, style: _biggerFont),
      onTap: deviceTapListener,
    );
  }
}
