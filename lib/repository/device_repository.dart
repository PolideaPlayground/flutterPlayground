
import 'package:wear_hint/model/ble_device.dart';

class DeviceRepository {

  BleDevice _bleDevice;

  static final DeviceRepository _deviceRepository = DeviceRepository._internal();

  factory DeviceRepository() {
    return _deviceRepository;
  }

  DeviceRepository._internal();


  void pickDevice(BleDevice bleDevice) {
    _bleDevice = bleDevice;
  }

  bool get hasPickedDevice => _bleDevice != null;

}