import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/device_details/device_details_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

import '../factory/factory.dart';
import '../mocks/mocks.dart';


class ObservableMock extends Mock implements Observable {}
class StreamMock<T> extends Mock implements Stream<T> {}
class StreamSubscriptionMock<T> extends Mock implements StreamSubscription<T> {}

void main() {

  group("Emiting devices ", () {
    test('should emit picked device on startup', () {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      BleDevice bleDevice = BleDeviceFactory.buildDisconnected();

      when(deviceRepository.pickedDevice).thenReturn(bleDevice);

      //when
      DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(
          FlutterBlueMock(), deviceRepository);

      //then
      expect(deviceDetailsBLoc.device.value, predicate((BleDevice device) => device.name == bleDevice.name));
    });

    test('should emit device from the lib', () {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      BleDevice disconnectedBleDevice = BleDevice.disconnected(
          "test", BluetoothDevice(name: "test", id: DeviceIdentifier("testId")),
          flutterBlueMock);

      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);
      when(flutterBlueMock.connect(any)).thenAnswer((_) =>
          Stream.fromIterable(
              [BluetoothDeviceState.connecting, BluetoothDeviceState.connected
              ]));

      //when
      DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(
          flutterBlueMock, deviceRepository);

      //then
      expectLater(deviceDetailsBLoc.device, emitsInOrder([
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.disconnected),
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.connecting),
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.connected),
      ]));

      //when part 2
      deviceDetailsBLoc.init();
    });
  });

  group("Connection", () {

    DeviceRepository deviceRepository;
    FlutterBlueMock flutterBlueMock;
    DisconnectedBleDeviceMock disconnectedBleDevice;
    DeviceDetailsBLoc deviceDetailsBLoc;

    setUp(() {
      deviceRepository = DeviceRepositoryMock();
      flutterBlueMock = FlutterBlueMock();
      disconnectedBleDevice = createDisconnectedBleDeviceMock(createConnectedBleDeviceMock());
//      deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);
      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);

      deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);
    });

    test("on startup should connect to the device from repository", () async {
      when(flutterBlueMock.connect(any)).thenAnswer((_) => Observable.never());

      //when
      deviceDetailsBLoc.init();

      //then
      await untilCalled(disconnectedBleDevice.connect());
    });

    test("should disconnect when backing to the list", () async {
      //given
      var connectedBleDevice = createConnectedBleDeviceMock();
      when(disconnectedBleDevice.connect()).thenAnswer((_) => Stream.fromIterable([connectedBleDevice]));

      await initBlocAndWaitForCompletion(deviceDetailsBLoc, disconnectedBleDevice);

      //when
      deviceDetailsBLoc.dispose();

      //then
      await untilCalled(connectedBleDevice.abandon());
    });

  });

  group("Temperature sensor", () {

    DeviceRepository deviceRepository;
    FlutterBlueMock flutterBlueMock;
    BleDevice disconnectedBleDevice;
    DeviceDetailsBLoc deviceDetailsBLoc;

    setUp(() {
      deviceRepository = DeviceRepositoryMock();
      flutterBlueMock = FlutterBlueMock();
      disconnectedBleDevice = BleDevice.disconnected("test",  BluetoothDevice(name: "test", id: DeviceIdentifier("testId")), flutterBlueMock);
      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);

      deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);
    });

    test("should turn on temperature sensor", () {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      BleDevice connectedBleDevice = BleDevice.connected("test", BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      //when

      //then
      expectLater(deviceDetailsBLoc.device, emitsInOrder([
        equals(disconnectedBleDevice),
        equals(connectedBleDevice),
      ]));
    });

  });


}

Future initBlocAndWaitForCompletion(DeviceDetailsBLoc deviceDetailsBLoc, DisconnectedBleDeviceMock disconnectedBleDeviceMock) async {
  deviceDetailsBLoc.init();
  await untilCalled(disconnectedBleDeviceMock.connect());
}

class BleDevicesMatcher extends Matcher {
  final BleDevice _expected;
  const BleDevicesMatcher(this._expected);
  bool matches(item, Map matchState) => (item as BleDevice).name == _expected.name;
  // If all types were hashable we could show a hash here.
  Description describe(Description description) =>
      description.add('same instance as ').addDescriptionOf(_expected);

  @override
  Description describeMismatch(item, Description mismatchDescription,
      Map matchState, bool verbose) {
    return StringDescription("expected: ${_expected.id}  emited: ${item.id}");
  }

}