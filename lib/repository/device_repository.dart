
import 'package:wear_hint/model/ble_device.dart';

class MissingPickedDeviceException implements Exception {}

class DeviceRepository {

  static BleDevice _bleDevice;

  static final DeviceRepository _deviceRepository = DeviceRepository
      ._internal();

  factory DeviceRepository() {
    return _deviceRepository;
  }

  DeviceRepository._internal();

  void pickDevice(BleDevice bleDevice) {
    _bleDevice = bleDevice;
  }

//  BleDevice get pickedDevice => _bleDevice != null ? _bleDevice : throw MissingPickedDeviceException();
  BleDevice get pickedDevice =>_bleDevice;

  bool get hasPickedDevice => _bleDevice != null;

}
