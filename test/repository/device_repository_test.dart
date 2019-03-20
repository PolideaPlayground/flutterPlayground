
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

import '../factory/factory.dart';

void main() {
  test("should not return device on fresh start", () {
    //given
    DeviceRepository deviceRepository = DeviceRepository();

    //when
    BleDevice storedBleDevice = deviceRepository.pickedDevice.value;

    //then
    expect(storedBleDevice, isNull);
  });

  test("should persist device repository", () {
    //given
    DeviceRepository deviceRepository = DeviceRepository();
    BleDevice bleDevice = BleDeviceFactory.buildDisconnected(name: "testqwe");
    ValueObservable<BleDevice> pickedDevice = deviceRepository.pickedDevice;

    //when
    deviceRepository.pickDevice(bleDevice);

    //then
    expectLater(pickedDevice, emits(equals(bleDevice)));
  });
}