
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/state/application_state.dart';

import '../factory/factory.dart';
import '../mocks/mocks.dart';

void main() {
  FlutterBlueMock flutterBlueMock;
  DeviceRepositoryMock deviceRepositoryMock;
  DevicesBloc devicesBloc;
  BleDevice bleDevice;

  setUp(() {
    flutterBlueMock = FlutterBlueMock();
    deviceRepositoryMock = DeviceRepositoryMock();
    bleDevice = BleDeviceFactory.buildDisconnected(bluetoothDevice: BluetoothDeviceFactory.build(name: "name1", id: "id1"));
    devicesBloc = DevicesBloc(flutterBlueMock, deviceRepositoryMock);

    when(flutterBlueMock.scan()).thenAnswer((_) => Observable.never());
  });

  test("should pass picked device to repo", () async  {
    //given
    devicesBloc.init();

    //when
    devicesBloc.devicePicker.add(bleDevice);

    //then
    await untilCalled(deviceRepositoryMock.pickDevice(argThat(equals(bleDevice))));
  });

  test("should pass info that a device has been picked", () {
    //given
    BehaviorSubject<BleDevice> devicePickerController = BehaviorSubject<BleDevice>();
    when(deviceRepositoryMock.pickedDevice).thenAnswer((_) => devicePickerController.stream);
    devicesBloc.init();
    var bleDevice = BleDeviceFactory.buildDisconnected();

    //then
    expectLater(devicesBloc.pickedDevice, emitsInOrder([
      equals(bleDevice),
    ]));

    //when
    devicePickerController.add(bleDevice);
  });
}