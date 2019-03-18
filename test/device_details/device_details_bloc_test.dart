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

    DeviceRepository deviceRepository;
    FlutterBlueMock flutterBlueMock;
    DisconnectedBleDeviceMock disconnectedBleDevice;
    DeviceDetailsBLoc deviceDetailsBLoc;

    setUp(() {
      deviceRepository = DeviceRepositoryMock();
      flutterBlueMock = FlutterBlueMock();
      disconnectedBleDevice = createDisconnectedBleDeviceMock();
      when(deviceRepository.pickedDevice).thenReturn(disconnectedBleDevice);

      deviceDetailsBLoc = DeviceDetailsBLoc(flutterBlueMock, deviceRepository);
    });

    test("on startup should connect to the device from repository", () async {
      when(flutterBlueMock.connect(any)).thenAnswer((_) => Observable.never());

      //when
      deviceDetailsBLoc.init();

      //then
      await untilCalled(disconnectedBleDevice.connect());
//      await untilCalled(flutterBlueMock.connect(argThat(equals(disconnectedBleDevice.bluetoothDevice))));
    });

    test("should disconnect when backing to the list", () async {
      //given
      StreamMock<BluetoothDeviceState> streamMock = StreamMock<BluetoothDeviceState>();
      StreamSubscriptionMock<BluetoothDeviceState> subscriptionMock = StreamSubscriptionMock<BluetoothDeviceState>();

      when(streamMock.listen(any)).thenAnswer((_) => subscriptionMock);
      when(flutterBlueMock.connect(any)).thenAnswer((_) => streamMock);

      await waitForInitCompletion(deviceDetailsBLoc, flutterBlueMock);

      //when
      deviceDetailsBLoc.dispose();

      //then
      await untilCalled(subscriptionMock.cancel());
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
      disconnectedBleDevice = BleDevice.disconnected("test",  BluetoothDevice(name: "test", id: DeviceIdentifier("testId")));
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

Future waitForInitCompletion(DeviceDetailsBLoc deviceDetailsBLoc, FlutterBlueMock flutterBlueMock) async {
  deviceDetailsBLoc.init();
  await untilCalled(flutterBlueMock.connect(any));
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