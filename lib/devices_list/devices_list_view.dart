import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/devices_list/devices_bloc_provider.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
      appBar: AppBar(
        title: Text('Bluetooth devices'),
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
  DevicesList(DevicesBloc devicesBloc, List<BleDevice> devices)
      : super.builder(
            // separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemCount: devices.length,
            itemBuilder: (context, i) {
              Fimber.d("Build row for $i");
              return _buildRow(context, devices[i],
                  _createTapListener(devicesBloc, devices[i]));
            });

  static DeviceTapListener _createTapListener(
      DevicesBloc devicesBloc, BleDevice bleDevice) {
    return () {
      Fimber.d("clicked device: ${bleDevice.name}");
      devicesBloc.devicePicker.add(bleDevice);
    };
  }

  static String _bluetoothDeviceTypeToString(BluetoothDeviceType type) {
    switch (type) {
      case BluetoothDeviceType.classic:
        return "Classic";
      case BluetoothDeviceType.dual:
        return "Dual-Mode";
      case BluetoothDeviceType.le:
        return "Low Energy";
      default:
        return "Unknown";
    }
  }

  static Widget _buildRow(BuildContext context, BleDevice device,
      DeviceTapListener deviceTapListener) {
    var isSensorTag = device.name == "SensorTag";
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isSensorTag
                  ? Image.asset('assets/ti_logo.png')
                  : Icon(Icons.bluetooth),
            ),
            backgroundColor: isSensorTag
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white),
      ),
      title: Text(device.name),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Icon(Icons.chevron_right, color: Colors.grey),
      ),
      subtitle: Column(
        children: <Widget>[
          Text(_bluetoothDeviceTypeToString(device.bluetoothDevice.type),
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).primaryColor)),
          Text(
            device.id.toString(),
            style: TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: deviceTapListener,
      isThreeLine: true,
    );
    // return Card(
    //   elevation: 8.0,
    //   margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    //   child: Container(
    //     decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
    //     child: ListTile(
    //       title: Text(device.name, style: _biggerFont),
    //       trailing:
    //           Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
    //       leading: Container(
    //         padding: EdgeInsets.only(right: 12.0),
    //         decoration: new BoxDecoration(
    //             border: new Border(
    //                 right: new BorderSide(width: 1.0, color: Colors.white24))),
    //         child: Icon(Icons.autorenew, color: Colors.white),
    //       ),
    //       onTap: deviceTapListener,
    //     ),
    //   ),
    // );
  }
}
