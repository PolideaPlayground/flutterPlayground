
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/model/ble_device.dart';

import '../mocks/mocks.dart';

class ScanResultFactory {

  static ScanResult build({BluetoothDevice bluetoothDevice,
                        String localName}) {
    return ScanResult(
        advertisementData: AdvertisementData(localName: localName ?? bluetoothDevice?.name ?? "localName"),
        device: bluetoothDevice ?? BluetoothDeviceFactory.build());
  }
}

class BluetoothDeviceFactory {
  static BluetoothDevice build({String name, String id}) {
    return BluetoothDevice(id: DeviceIdentifier(id ?? "test_id"), name: name ?? "device_name");
  }
}

class BleDeviceFactory {
  static BleDevice buildDisconnected({String name, BluetoothDevice bluetoothDevice, FlutterBlue flutterBlue}) {
    return BleDevice.disconnected(
        bluetoothDevice?.name ?? "test",
        bluetoothDevice ?? BluetoothDeviceFactory.build(),
        flutterBlue ?? FlutterBlueMock()
    );
  }
}