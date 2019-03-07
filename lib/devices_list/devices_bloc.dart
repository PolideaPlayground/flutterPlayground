import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';
import 'package:wear_hint/state/application_state.dart';

class DevicesBloc {
  final List<BleDevice> bleDevices = <BleDevice>[];

  final BehaviorSubject<List<BleDevice>> _visibleDevicesController =
      BehaviorSubject<List<BleDevice>>(seedValue: <BleDevice>[]);

  final _devicePickerController = StreamController<BleDevice>();
  final _applicationStateController = StreamController<ApplicationState>();

  Stream<ApplicationState> get applicationState => _applicationStateController.stream;

  StreamSubscription<ScanResult> _scanSubscription;

  ValueObservable<List<BleDevice>> get visibleDevices =>
      _visibleDevicesController.stream;

  Sink<BleDevice> get devicePicker => _devicePickerController.sink;

  FlutterBlue _flutterBlue;
  DeviceRepository _deviceRepository;

  DevicesBloc(this._flutterBlue, this._deviceRepository) {
    _flutterBlue.setLogLevel(LogLevel.error);
  }

  void _handlePickedDevice(BleDevice bleDevice) {
    _deviceRepository.pickDevice(bleDevice);
    _applicationStateController.add(ApplicationState.DEVICE_PICKED);
  }

  void dispose() {
    _visibleDevicesController.close();
    _devicePickerController.close();
    _scanSubscription?.cancel();
    _applicationStateController?.close();
  }

  void init() {
    _scanSubscription = _flutterBlue.scan().listen((ScanResult scanResult) {
      var bleDevice = BleDevice.disconnected(
          scanResult.advertisementData.localName, scanResult.device);
      if (scanResult.advertisementData.localName.isNotEmpty &&
          !bleDevices.contains(bleDevice)) {
        print(
            'found new device ${scanResult.advertisementData
                .localName} ${scanResult.device.id}');
        bleDevices.add(bleDevice);
        _visibleDevicesController.add(bleDevices.sublist(0));
      }
    });
    print("Init");

    _devicePickerController.stream.listen(_handlePickedDevice);
  }
}
