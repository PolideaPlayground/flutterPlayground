
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

    await untilCalled(deviceRepositoryMock.pickDevice(argThat(equals(bleDevice))));
  });

  test("should change app state once device is picked", () {
    //given
    devicesBloc.init();

    //then
    expectLater(devicesBloc.applicationState, emitsInOrder([
      ApplicationState.DEVICE_PICKED,
    ]));

    //when
    devicesBloc.devicePicker.add(bleDevice);
  });
}