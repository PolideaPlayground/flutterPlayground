
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/model/ble_device.dart';

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
  static BleDevice buildDisconnected({String name, BluetoothDevice bluetoothDevice}) {
    return BleDevice.disconnected(
        bluetoothDevice?.name ?? "test",
        bluetoothDevice ?? BluetoothDeviceFactory.build()
    );
  }
}