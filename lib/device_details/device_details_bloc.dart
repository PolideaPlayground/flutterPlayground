
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

class DeviceDetailsBLoc {
  final FlutterBlue _flutterBlue;
  final DeviceRepository _deviceRepository;

  BehaviorSubject<BleDevice> _deviceController;

  ValueObservable<BleDevice> get device => _deviceController.stream;

  DeviceDetailsBLoc(this._flutterBlue, this._deviceRepository){
    _flutterBlue.setLogLevel(LogLevel.error);

    _deviceController =
        BehaviorSubject<BleDevice>(seedValue: _deviceRepository.pickedDevice);

  }

  void init() {
    _deviceController.stream.listen((bleDevice) {

      if (bleDevice.bluetoothDeviceState == BluetoothDeviceState.disconnected) {
        _flutterBlue.connect(bleDevice.bluetoothDevice).listen((connectionState) {
          BleDevice newBleDevice = BleDevice.disconnected(bleDevice.name, bleDevice.bluetoothDevice)..bluetoothDeviceState = connectionState;
          _deviceController.add(newBleDevice);
        });
          return;
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

  void dispose() {
    _deviceController.close();
  }


}