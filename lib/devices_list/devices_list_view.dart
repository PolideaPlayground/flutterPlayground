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
    _appStateSubscription = _devicesBloc.pickedDevice.listen((bleDevice) async {
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

class _HexPainter extends CustomPainter {
  const _HexPainter({
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  }) : super();

  final Color foregroundColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = backgroundColor;
    paint.strokeWidth = size.width * 0.5;
    paint.strokeJoin = StrokeJoin.round;
    paint.style = PaintingStyle.stroke;
    var path = Path();
    path.addPolygon([
      Offset(size.width * 0.25, size.height * 0.375),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.375),
      Offset(size.width * 0.75, size.height * 0.625),
      Offset(size.width * 0.5, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.625)
    ], true);
    canvas.drawPath(path, paint);

    paint.color = foregroundColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.23),
        size.height * 0.08, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DevicesList extends ListView {
  DevicesList(DevicesBloc devicesBloc, List<BleDevice> devices)
      : super.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  height: 0,
                  indent: 0,
                ),
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

  static Widget _buildAvatar(BuildContext context, BleDevice device) {
    if (device.name == "SensorTag") {
      return CircleAvatar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/ti_logo.png'),
          ),
          backgroundColor: Theme.of(context).accentColor);
    } else if (device.name.startsWith("Hex")) {
      return CircleAvatar(
          child: CustomPaint(painter: _HexPainter(), size: Size(20, 24)),
          backgroundColor: Colors.black);
    }
    return CircleAvatar(
        child: Icon(Icons.bluetooth),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white);
  }

  static Widget _buildRow(BuildContext context, BleDevice device,
      DeviceTapListener deviceTapListener) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _buildAvatar(context, device),
      ),
      title: Text(device.name),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 16),
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
      contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
    );
  }
}
