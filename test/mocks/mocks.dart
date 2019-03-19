
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

class FlutterBlueMock extends Mock implements FlutterBlue {}
class DeviceRepositoryMock extends Mock implements DeviceRepository {}
class BluetoothDeviceMock extends Mock implements BluetoothDevice {}

class DisconnectedBleDeviceMock extends Mock implements DisconnectedBleDevice {}
class ConnectedBleDeviceMock extends Mock implements ConnectedBleDevice {}


ConnectedBleDeviceMock createConnectedBleDeviceMock() {
  var bleDevice = ConnectedBleDeviceMock();
  when(bleDevice.bluetoothDeviceState).thenReturn(BluetoothDeviceState.connected);
  return bleDevice;
}

DisconnectedBleDeviceMock createDisconnectedBleDeviceMock(ConnectedBleDeviceMock connectedBleDevice) {
  var bleDevice = DisconnectedBleDeviceMock();
  when(bleDevice.bluetoothDeviceState).thenReturn(BluetoothDeviceState.disconnected);
  //TODO update sdk
  when(bleDevice.connect()).thenAnswer((_) => Stream.fromIterable([connectedBleDevice]));
  return bleDevice;
}