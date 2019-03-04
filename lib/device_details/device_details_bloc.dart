
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

class DeviceDetailsBLoc {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final DeviceRepository _deviceRepository = DeviceRepository();

  BehaviorSubject<BleDevice> _deviceController;

  ValueObservable<BleDevice> get device => _deviceController.stream;

  DeviceDetailsBLoc(){
    flutterBlue.setLogLevel(LogLevel.error);

    _deviceController =
        BehaviorSubject<BleDevice>(seedValue: _deviceRepository.pickedDevice);

    _deviceController.stream.listen((bleDevice) {
      if (bleDevice.bluetoothDeviceState == BluetoothDeviceState.disconnected) {
        flutterBlue.connect(bleDevice.bluetoothDevice).listen((connectionState) {
          _deviceController.add(bleDevice..bluetoothDeviceState = connectionState);
        });
      }

      if(bleDevice.bluetoothDeviceState == BluetoothDeviceState.connected) {
        discoverServices((bleDevice as DisconnectedBleDevice).toConnected(bleDevice));
      }
    });
  }

  void discoverServices(ConnectedBleDevice bleDevice) async {
    List<BluetoothService> services = await bleDevice.bluetoothDevice.discoverServices();
    _deviceController.add(bleDevice..services = services);
  }


}