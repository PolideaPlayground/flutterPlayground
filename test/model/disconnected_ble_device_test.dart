
import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:wear_hint/model/ble_device.dart';

import '../device_details/device_details_bloc_test.dart';
import '../factory/factory.dart';
import '../mocks/mocks.dart';

void main() {

  FlutterBlueMock flutterBlueMock;
  BluetoothDevice bluetoothDevice;
  DisconnectedBleDevice disconnectedBleDevice;
  StreamMock<BluetoothDeviceState> streamMock;
  StreamSubscriptionMock<BluetoothDeviceState> subscriptionMock;

  setUp(() {
    flutterBlueMock = FlutterBlueMock();
    bluetoothDevice = BluetoothDeviceFactory.build();
    disconnectedBleDevice = DisconnectedBleDevice("test1", DeviceIdentifier("test_id"), bluetoothDevice, flutterBlueMock);
    streamMock = StreamMock<BluetoothDeviceState>();
    subscriptionMock = StreamSubscriptionMock<BluetoothDeviceState>();
  });

  test("should try to connect", () async {
    //given
    when(streamMock.listen(any)).thenAnswer((_) => subscriptionMock);
    when(flutterBlueMock.connect(any)).thenAnswer((_) => streamMock);

    //when
    disconnectedBleDevice.connect();

    //then
    await untilCalled(flutterBlueMock.connect(argThat(equals(bluetoothDevice))));
  });

  test("should close connection when abandon connection process", () async {
    //given
    when(streamMock.listen(any)).thenAnswer((_) => subscriptionMock);
    when(flutterBlueMock.connect(any)).thenAnswer((_) => streamMock);

    //when
    disconnectedBleDevice.connect();
    disconnectedBleDevice.abandon();

    //then
    await untilCalled(subscriptionMock.cancel());
  });

  test("should emit ble device in all states determined by connection state", () {
    //given
    StreamController<BleDevice> fake = StreamController<BleDevice>();
    when(flutterBlueMock.connect(any)).thenAnswer((_) => Stream.fromIterable([BluetoothDeviceState.connecting, BluetoothDeviceState.connected]));

    //then
    expectLater(fake.stream, emitsInOrder([
      predicate((BleDevice bleDevice) => bleDevice.bluetoothDeviceState == BluetoothDeviceState.connecting),
      predicate((BleDevice bleDevice) => bleDevice.bluetoothDeviceState == BluetoothDeviceState.connected),
    ]));

    //when
    disconnectedBleDevice.connect().pipe(fake);
  });

}