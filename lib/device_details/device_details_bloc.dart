
import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';
import 'package:wear_hint/sensor_tag/sensor_tag.dart';
import 'dart:typed_data';
import 'dart:math';

class DeviceDetailsBLoc {
  final FlutterBlue _flutterBlue;
  final DeviceRepository _deviceRepository;

  BehaviorSubject<BleDevice> _deviceController;

  ValueObservable<BleDevice> get device => _deviceController.stream;

  StreamSubscription connectionSubscription;

  Stream<BleDevice> _devicesInConnectingProcess;

  DeviceDetailsBLoc(this._flutterBlue, this._deviceRepository){
    _flutterBlue.setLogLevel(LogLevel.error);

    _deviceController =
        BehaviorSubject<BleDevice>(seedValue: _deviceRepository.pickedDevice);

  }

  void init() {
    Fimber.d("init bloc");
    _deviceController.stream.listen((bleDevice) {

      if (bleDevice.bluetoothDeviceState == BluetoothDeviceState.disconnected) {
        _devicesInConnectingProcess = (bleDevice as DisconnectedBleDevice).connect();
        _devicesInConnectingProcess.pipe(_deviceController);
        return;
      }

//      if(bleDevice.bluetoothDeviceState == BluetoothDeviceState.connected && bleDevice is DisconnectedBleDevice) {
//        discoverServices((bleDevice as DisconnectedBleDevice).toConnected(bleDevice));
//      }
    });
  }

  int _shortUnsignedAtOffset(Uint8List c, int offset) {
    var lsb = c[offset];
    int lowerByte = lsb & 0xFF;

    var msb = c[offset+1];
    int upperByte = msb & 0xFF; // // Interpret MSB as signed
    var upperMoved = (upperByte << 8);
    return upperMoved + lowerByte;
  }

  double _extractAmbientTemperature(Uint8List v) {
    int offset = 2;
    return _shortUnsignedAtOffset(v, offset) / 128.0;
  }

  int _shortSignedAtOffset(Uint8List c, int offset) {
    int lowerByte = c[offset] & 0xFF;
    int upperByte = c[offset+1]; // // Interpret MSB as signed
    return (upperByte << 8) + lowerByte;
  }

  double _extractTargetTemperature(Uint8List v, double ambient) {
    int twoByteValue = _shortSignedAtOffset(v, 0);

    double Vobj2 = twoByteValue.toDouble();
    Vobj2 *= 0.00000015625;

    double Tdie = ambient + 273.15;

    double S0 = 5.593E-14; // Calibration factor
    double a1 = 1.75E-3;
    double a2 = -1.678E-5;
    double b0 = -2.94E-5;
    double b1 = -5.7E-7;
    double b2 = 4.63E-9;
    double c2 = 13.4;
    double Tref = 298.15;
    double S = S0 * (1 + a1 * (Tdie - Tref) + a2 * pow((Tdie - Tref), 2));
    double Vos = b0 + b1 * (Tdie - Tref) + b2 * pow((Tdie - Tref), 2);
    double fObj = (Vobj2 - Vos) + c2 * pow((Vobj2 - Vos), 2);
    double tObj = pow(pow(Tdie, 4) + (fObj / S), .25);

    return tObj - 273.15;
  }

  double coverToCelcius(Uint8List values) {
    double ambient = _extractAmbientTemperature(values);
    double target = _extractTargetTemperature(values, ambient);
    Fimber.d("Convert to celcius $values -> ambient: [$ambient]\ttarget: [$target]");
    return target;
  }

  void discoverServices(ConnectedBleDevice bleDevice) async {
    List<BluetoothService> services = await bleDevice.bluetoothDevice.discoverServices();
    _deviceController.add(bleDevice..services = services);
    services.forEach((service) async {
      Fimber.d("Service: ${service.uuid}");
      if (service.uuid.toString() == SensorTag.IR_SERVICE) {
        var characteristics = service.characteristics;
        Fimber.d("Found IR service, has ${characteristics.length} characteristics");
        for(BluetoothCharacteristic c in characteristics) {
          List<int> values = await bleDevice.bluetoothDevice.readCharacteristic(c);
          Fimber.d("charasteristic: ${c.uuid} ");
          values.forEach((value) => Fimber.d("\t value ${value}"));
          if(c.uuid.toString() == SensorTag.IR_CONF) {
            Fimber.d("\n\tfound ir conf characteristic and write 1");
            await bleDevice.bluetoothDevice.writeCharacteristic(c, [0x1]);
            Fimber.d("\tafter write");
            List<int> values = await bleDevice.bluetoothDevice.readCharacteristic(c);
            Fimber.d("\CONF characteristic: ${c.uuid} ");
            values.forEach((value) => Fimber.d("\t\t ${value}"));
          }
        }

        for(BluetoothCharacteristic c in characteristics) {
          if(c.uuid.toString() == SensorTag.IR_DATA) {
            Fimber.d("\n\listern temperature ${c.uuid}");

            await bleDevice.bluetoothDevice.setNotifyValue(c, true);
            bleDevice.bluetoothDevice.onValueChanged(c).listen((value) {
              Fimber.d("\n\t ---> temperature haas changed ${coverToCelcius(value)}");
            });
          }
        }

      }
    });

  }

  void dispose() async {
    _deviceController.value?.abandon();
//    _devicesInConnectingProcess.
    await _deviceController.drain();
    _deviceController.close();
  }

}