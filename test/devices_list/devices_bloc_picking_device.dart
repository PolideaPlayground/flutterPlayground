
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';

import '../factory/factory.dart';
import '../mocks/mocks.dart';

void main() {
  FlutterBlueMock flutterBlueMock;
  DeviceRepositoryMock deviceRepositoryMock;
  DevicesBloc devicesBloc;
  BleDevice bleDevice1;


  setUp(() {
    flutterBlueMock = FlutterBlueMock();
    deviceRepositoryMock = DeviceRepositoryMock();
    bleDevice1 = BleDeviceFactory.buildDisconnected(bluetoothDevice: BluetoothDeviceFactory.build(name: "name1", id: "id1"));
    devicesBloc = DevicesBloc(flutterBlueMock, deviceRepositoryMock);

    when(flutterBlueMock.scan()).thenAnswer((_) => Observable.never());
  });

  test("should pass picked device to repo", () async  {
    //given
    devicesBloc.init();

    //when
    devicesBloc.devicePicker.add(bleDevice1);

    await untilCalled(deviceRepositoryMock.pickDevice(argThat(equals(bleDevice1))));
  });
}