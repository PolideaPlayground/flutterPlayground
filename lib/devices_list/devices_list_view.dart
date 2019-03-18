import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/devices_list/devices_bloc_provider.dart';
import 'package:wear_hint/model/ble_device.dart';

typedef DeviceTapListener = void Function();

class DevicesListScreen extends StatefulWidget {
  @override
  State<DevicesListScreen> createState() => DeviceListScreenState();
}

class DeviceListScreenState extends State<DevicesListScreen> {
  DevicesBloc _devicesBloc;
  StreamSubscription _appStateSubscription;

  @override
  void didUpdateWidget(DevicesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    Fimber.d("didUpdateWidget");
  }

  void _onPause() {
    Fimber.d("onPause");
    _appStateSubscription.cancel();
    _devicesBloc.dispose();
  }

  void _onResume() {
    Fimber.d("onResume");
    _devicesBloc.init();
    _appStateSubscription =
        _devicesBloc.applicationState.listen((applicationState) async {
      Fimber.d("navigate to details");
      _onPause();
      await Navigator.pushNamed(context, "/details");
      _shouldRunOnResume = true;
      Fimber.d("back from details");
    });
  }

  bool _shouldRunOnResume = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Fimber.d("DeviceListScreenState didChangeDependencies");
    if (_devicesBloc == null) {
      _devicesBloc = DevicesBlocProvider.of(context);
      if (_shouldRunOnResume) {
        _shouldRunOnResume = false;
        _onResume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Fimber.d("build DeviceListScreenState");
    if (_shouldRunOnResume) {
      _shouldRunOnResume = false;
      _onResume();
    }
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
    Fimber.d("Dispose DeviceListScreenState");
    _onPause();
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivate");
    super.deactivate();
  }

  @override
  void reassemble() {
    Fimber.d("reassemble");
    super.reassemble();
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
              Fimber.d("Build row for $i");
              return _buildRow(
                  devices[i], _createTapListener(devicesBloc, devices[i]));
            });

  static DeviceTapListener _createTapListener(
      DevicesBloc devicesBloc, BleDevice bleDevice) {
    return () {
      Fimber.d("clicked device: ${bleDevice.name}");
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
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
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
