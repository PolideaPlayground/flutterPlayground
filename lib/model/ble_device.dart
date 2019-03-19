import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class BleDevice {
  int counter = 0;
  final String name;
  final DeviceIdentifier id;
  final BluetoothDevice bluetoothDevice;
  BluetoothDeviceState bluetoothDeviceState = BluetoothDeviceState.disconnected;

  bool get isConnected => bluetoothDeviceState == BluetoothDeviceState.connected;

  BleDevice(this.name, this.id, this.bluetoothDevice, this.bluetoothDeviceState);

  factory BleDevice.connected(String name, BluetoothDevice bluetoothDevice) {
    return ConnectedBleDevice(name, bluetoothDevice.id, bluetoothDevice);
  }

  factory BleDevice.disconnected(String name, BluetoothDevice bluetoothDevice, FlutterBlue flutterBlue) {
    return DisconnectedBleDevice(name, bluetoothDevice.id, bluetoothDevice, flutterBlue);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) =>
      other is BleDevice && compareAsciiLowerCase(this.id.id, other.id.id) == 0;

  @override
  String toString() {
    return 'BleDevice{counter: $counter, name: $name, id: $id, bluetoothDevice: $bluetoothDevice, bluetoothDeviceState: $bluetoothDeviceState}';
  }

  void abandon();

}

class DisconnectedBleDevice extends BleDevice {

  FlutterBlue _flutterBlue;
  StreamSubscription<BluetoothDeviceState> _connectionSubscription;
  StreamController<BleDevice> _devicesInConnectingProcess;

  DisconnectedBleDevice(String name, DeviceIdentifier id, BluetoothDevice bluetoothDevice, this._flutterBlue)
      : super(name, id, bluetoothDevice, BluetoothDeviceState.disconnected);

  ConnectedBleDevice toConnected() {
    return ConnectedBleDevice.fromDisconnected(this, _connectionSubscription);
  }

  @override
  String toString() {
    return 'DisconnectedBleDevice{} ${super.toString()}';
  }

  Stream<BleDevice> connect() {
    _devicesInConnectingProcess?.close();
    _devicesInConnectingProcess = StreamController<BleDevice>();
    _connectionSubscription = _flutterBlue.connect(bluetoothDevice).listen((connectionState) {
      if(connectionState == BluetoothDeviceState.connecting) {
        BleDevice newBleDevice = BleDevice.disconnected(name, bluetoothDevice, _flutterBlue)..bluetoothDeviceState = connectionState;
        _devicesInConnectingProcess.add(newBleDevice);
      }

      if (connectionState == BluetoothDeviceState.connected) {
        _devicesInConnectingProcess.add(toConnected());
        _devicesInConnectingProcess.close();
      }
    });
    return _devicesInConnectingProcess.stream;
  }

  void abandon() {
    _connectionSubscription?.cancel();
    _devicesInConnectingProcess?.close();
  }
}

class ConnectedBleDevice extends BleDevice {

  List<BluetoothService> services;
  StreamSubscription<BluetoothDeviceState> _connectionSubscription;

  ConnectedBleDevice(String name, DeviceIdentifier id, BluetoothDevice bluetoothDevice)
      : super(name, id, bluetoothDevice, BluetoothDeviceState.connected);

  ConnectedBleDevice.fromDisconnected(DisconnectedBleDevice disconnectedBleDevice, this._connectionSubscription)
      : super(disconnectedBleDevice.name, disconnectedBleDevice.id,
        disconnectedBleDevice.bluetoothDevice, BluetoothDeviceState.connected);

  void abandon() {
    _connectionSubscription?.cancel();
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write("ConnectedBleDevice\n");
    buffer.write("name: $name\n");
    services?.forEach((service) => buffer.write("${service.uuid}\n\n"));
    return buffer.toString();
  }
}
