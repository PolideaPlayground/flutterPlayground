import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/device_details/device_details_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';
import 'package:wear_hint/sensor_tag/sensor_tag.dart';

import '../factory/factory.dart';
import '../mocks/mocks.dart';


class ObservableMock extends Mock implements Observable {}
class StreamMock<T> extends Mock implements Stream<T> {}
class StreamSubscriptionMock<T> extends Mock implements StreamSubscription<T> {}

class SensorTagFactoryMock extends Mock implements SensorTagFactory {}
class SensorTagMock extends Mock implements SensorTag {}

void main() {

  SensorTagFactoryMock sensorTagFactory;
  FlutterBlueMock flutterBlueMock;
  DeviceRepository deviceRepository;
  SensorTagMock sensorTag;

  setUp(() {
    sensorTagFactory = SensorTagFactoryMock();
    flutterBlueMock = FlutterBlueMock();
    deviceRepository = DeviceRepositoryMock();

    sensorTag = SensorTagMock();
    when(sensorTag.ambientTemperature).thenAnswer((_) => BehaviorSubject<double>());
    when(sensorTagFactory.create(any)).thenReturn(sensorTag);
  });

  group("Emiting devices ", () {
    test('should emit picked device on startup', () {
      //given
      BleDevice bleDevice = BleDeviceFactory.buildDisconnected();

      when(deviceRepository.pickedDevice).thenAnswer((_) => BehaviorSubject(seedValue: bleDevice));

      //when
      DeviceDetailsBloc deviceDetailsBloc = DeviceDetailsBloc(
          FlutterBlueMock(), deviceRepository);

      //then
      expect(deviceDetailsBloc.device.value, predicate((BleDevice device) => device.name == bleDevice.name));
    });

    test('should emit device from the lib', () {
      //given
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      BleDevice disconnectedBleDevice = BleDevice.disconnected(
          "test", BluetoothDevice(name: "test", id: DeviceIdentifier("testId")),
          flutterBlueMock);

      when(deviceRepository.pickedDevice).thenAnswer((_) => BehaviorSubject(seedValue: disconnectedBleDevice));
      when(flutterBlueMock.connect(any)).thenAnswer((_) =>
          Stream.fromIterable(
              [BluetoothDeviceState.connecting, BluetoothDeviceState.connected
              ]));

      //when
      DeviceDetailsBloc deviceDetailsBloc = DeviceDetailsBloc(
          flutterBlueMock, deviceRepository, sensorTagFactory: sensorTagFactory);

      //then
      expectLater(deviceDetailsBloc.device, emitsInOrder([
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.disconnected),
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.connecting),
        predicate((BleDevice device) => device.bluetoothDeviceState == BluetoothDeviceState.connected),
      ]));

      //when part 2
      deviceDetailsBloc.init();
    });
  });

  group("Connection", () {

    DisconnectedBleDeviceMock disconnectedBleDevice;
    DeviceDetailsBloc deviceDetailsBloc;

    setUp(() {
      disconnectedBleDevice = createDisconnectedBleDeviceMock(createConnectedBleDeviceMock());
      when(deviceRepository.pickedDevice).thenAnswer((_) => BehaviorSubject(seedValue: disconnectedBleDevice));

      deviceDetailsBloc = DeviceDetailsBloc(flutterBlueMock, deviceRepository, sensorTagFactory: sensorTagFactory);
    });

    test("on startup should connect to the device from repository", () async {
      //given
      when(flutterBlueMock.connect(any)).thenAnswer((_) => Observable.never());

      //when
      deviceDetailsBloc.init();

      //then
      await untilCalled(disconnectedBleDevice.connect());
    });

    test("should disconnect when backing to the list", () async {
      //given
      var connectedBleDevice = createConnectedBleDeviceMock();
      when(disconnectedBleDevice.connect()).thenAnswer((_) => Stream.fromIterable([connectedBleDevice]));

      await initBlocAndWaitForCompletion(deviceDetailsBloc, disconnectedBleDevice);

      //when
      deviceDetailsBloc.dispose();

      //then
      await untilCalled(connectedBleDevice.abandon());
    });

  });

  group("Sensor tag", () {

    setUp(() {
      when(flutterBlueMock.connect(any)).thenAnswer((_) => Stream.fromIterable([BluetoothDeviceState.connected]));
      DisconnectedBleDevice disconnectedBleDevice = createDisconnectedBleDeviceMock(createConnectedBleDeviceMock());
      when(deviceRepository.pickedDevice).thenAnswer((_) => BehaviorSubject(seedValue: disconnectedBleDevice));
    });

    test("should turn sensors on", () async {
      //given
      DeviceDetailsBloc deviceDetailsBloc = DeviceDetailsBloc(flutterBlueMock, deviceRepository, sensorTagFactory: sensorTagFactory);

      //when
      deviceDetailsBloc.init();

      //then
      await untilCalled(sensorTag.initAllSensors());
    });

    test("should listen ambient temperature", () async {
      //given
      DeviceDetailsBloc deviceDetailsBloc = DeviceDetailsBloc(flutterBlueMock, deviceRepository, sensorTagFactory: sensorTagFactory);
      when(sensorTag.ambientTemperature).thenAnswer((_) => Observable.fromIterable([12.4,37.5,89.9]).shareValue());

      //when
      deviceDetailsBloc.init();
      await untilCalled(sensorTag.initAllSensors());

      //then
      expectLater(deviceDetailsBloc.ambientTemperature, emitsInOrder([equals(12.4), equals(37.5), equals(89.9)]));
    });

  });
}

Future initBlocAndWaitForCompletion(DeviceDetailsBloc deviceDetailsBloc, DisconnectedBleDeviceMock disconnectedBleDeviceMock) async {
  deviceDetailsBloc.init();
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