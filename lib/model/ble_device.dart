import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleDevice {
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

  factory BleDevice.disconnected(String name, BluetoothDevice bluetoothDevice) {
    return DisconnectedBleDevice(name, bluetoothDevice.id, bluetoothDevice);
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

}

class DisconnectedBleDevice extends BleDevice {
  DisconnectedBleDevice(String name, DeviceIdentifier id, BluetoothDevice bluetoothDevice)
      : super(name, id, bluetoothDevice, BluetoothDeviceState.disconnected);

  ConnectedBleDevice toConnected(BleDevice bleDevice) {
    return ConnectedBleDevice.fromDisconnected(this);
  }

  @override
  String toString() {
    return "Device \n"
        "${name} \n"
        " isConnected: ${bluetoothDeviceState}";
  }
}

class ConnectedBleDevice extends BleDevice {

  List<BluetoothService> services;

  ConnectedBleDevice(String name, DeviceIdentifier id, BluetoothDevice bluetoothDevice)
      : super(name, id, bluetoothDevice, BluetoothDeviceState.connected);

  ConnectedBleDevice.fromDisconnected(DisconnectedBleDevice disconnectedBleDevice)
      : super(disconnectedBleDevice.name, disconnectedBleDevice.id,
        disconnectedBleDevice.bluetoothDevice, BluetoothDeviceState.connected);

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write("ConnectedBleDevice\n");
    buffer.write("name: $name\n");
    services?.forEach((service) => buffer.write("${service.uuid}\n\n"));
    return buffer.toString();
  }


}
