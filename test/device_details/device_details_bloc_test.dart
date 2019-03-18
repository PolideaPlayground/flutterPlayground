import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/device_details/device_details_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:wear_hint/repository/device_repository.dart';

import '../mocks/mocks.dart';


class ObservableMock extends Mock implements Observable {}
class StreamMock<T> extends Mock implements Stream<T> {}
class StreamSubscriptionMock<T> extends Mock implements StreamSubscription<T> {}

void main() {
  test('should emit picked device on startup', () {
    //given
    DeviceRepository deviceRepository = DeviceRepositoryMock();
    BleDevice bleDevice = BleDevice("test", DeviceIdentifier("testId"),
        BluetoothDeviceMock(), BluetoothDeviceState.connecting);

    when(deviceRepository.pickedDevice).thenReturn(bleDevice);

    //when
    DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(FlutterBlueMock(), deviceRepository);

    //then
    expect(deviceDetailsBLoc.device.value, equals(bleDevice));
  });

  test('should emit device from the lib', () {
    //given
    DeviceRepository deviceRepository = DeviceRepositoryMock();
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    BleDevice disconnectedBleDevice = BleDevice.disconnected("test",  BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));
    BleDevice connectedBleDevice = BleDevice.connected("test", BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));

    when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);
    when(flutterBlueMock.connect(any)).thenAnswer((_) => BehaviorSubject<BluetoothDeviceState>(seedValue: BluetoothDeviceState.connected));

    //when
    DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);

    //then
    expectLater(deviceDetailsBLoc.device, emitsInOrder([
      equals(disconnectedBleDevice),
      equals(connectedBleDevice),
    ]));

    //when part 2
    deviceDetailsBLoc.init();
  });

  group("Connection", () {

    setUp(() {

    });

    test("on startup should connect to the device from repository", () async {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      BleDevice disconnectedBleDevice = BleDevice.disconnected("test",  BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));

      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);

      when(flutterBlueMock.connect(any)).thenAnswer((_) => Observable.never());

      //when
      DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);
      deviceDetailsBLoc.init();

      //then
      await untilCalled(flutterBlueMock.connect(argThat(equals(disconnectedBleDevice.bluetoothDevice))));
    });

    test("should disconnect when backing to the list", () async {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      BleDevice disconnectedBleDevice = BleDevice.disconnected("test",  BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));


      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);

      DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);

      StreamMock<BluetoothDeviceState> streamMock = StreamMock<BluetoothDeviceState>();
      StreamSubscriptionMock<BluetoothDeviceState> subscriptionMock = StreamSubscriptionMock<BluetoothDeviceState>();

      when(streamMock.listen(any)).thenAnswer((_) => subscriptionMock);
      when(flutterBlueMock.connect(any)).thenAnswer((_) => streamMock);

      deviceDetailsBLoc.init();
      await untilCalled(flutterBlueMock.connect(any));

      //when
      deviceDetailsBLoc.dispose();

      //then
      await untilCalled(subscriptionMock.cancel());
    });

  });


  group("Temperature sensor", () {

    test("should not emit value until collect result from a device", () {
      //given
      DeviceRepository deviceRepository = DeviceRepositoryMock();
      BleDevice connectedBleDevice = BleDevice.connected("test", BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));
      FlutterBlueMock flutterBlueMock = FlutterBlueMock();
      //when

      //then
      expect(1,3);
    });

  });


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