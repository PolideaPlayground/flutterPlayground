import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';
import 'package:wear_hint/state/application_state.dart';

class DevicesBloc {
  final List<BleDevice> bleDevices = <BleDevice>[];

  BehaviorSubject<List<BleDevice>> _visibleDevicesController =
      BehaviorSubject<List<BleDevice>>(seedValue: <BleDevice>[]);

  StreamController<BleDevice> _devicePickerController = StreamController<BleDevice>();
  StreamController<ApplicationState> _applicationStateController = StreamController<ApplicationState>();

  Stream<ApplicationState> get applicationState => _applicationStateController.stream;

  StreamSubscription<ScanResult> _scanSubscription;
  StreamSubscription _devicePickerSubscription;

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
    Fimber.d("cancel _devicePickerSubscription");
    _devicePickerSubscription.cancel();
    _visibleDevicesController.close();
    _devicePickerController.close();
    _scanSubscription?.cancel();
    _applicationStateController?.close();
  }

  void init() {
    if (_visibleDevicesController.isClosed) {
      _visibleDevicesController = BehaviorSubject<List<BleDevice>>(seedValue: <BleDevice>[]);
    }

    if (_devicePickerController.isClosed) {
      _devicePickerController = StreamController<BleDevice>();
    }

    if (_applicationStateController.isClosed) {
      _applicationStateController = StreamController<ApplicationState>();
    }

    _scanSubscription = _flutterBlue.scan().listen((ScanResult scanResult) {
      var bleDevice = BleDevice.disconnected(
          scanResult.advertisementData.localName, scanResult.device, _flutterBlue);
      if (scanResult.advertisementData.localName.isNotEmpty &&
          !bleDevices.contains(bleDevice)) {
        Fimber.d(
            'found new device ${scanResult.advertisementData
                .localName} ${scanResult.device.id}');
        bleDevices.add(bleDevice);
        _visibleDevicesController.add(bleDevices.sublist(0));
      }
    });

    Fimber.d(" listen to _devicePickerController.stream");
    _devicePickerSubscription = _devicePickerController.stream.listen(_handlePickedDevice);
  }
}
