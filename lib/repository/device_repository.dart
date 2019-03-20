
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';

class MissingPickedDeviceException implements Exception {}

class DeviceRepository {

  static BleDevice _bleDevice;
  BehaviorSubject<BleDevice> _deviceController;

  static final DeviceRepository _deviceRepository = DeviceRepository
      ._internal();

  factory DeviceRepository() {
    return _deviceRepository;
  }

  DeviceRepository._internal() {
    _deviceController = BehaviorSubject<BleDevice>(seedValue: _bleDevice);
  }

  void pickDevice(BleDevice bleDevice) {
    _bleDevice = bleDevice;
    _deviceController.add(_bleDevice);
  }

  ValueObservable<BleDevice> get pickedDevice => _deviceController.stream.shareValue(seedValue: _bleDevice);

  bool get hasPickedDevice => _bleDevice != null;

}
