
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
  ConnectedBleDevice connectedBleDevice;
  StreamMock<BluetoothDeviceState> streamMock;
  StreamSubscriptionMock<BluetoothDeviceState> connectionSubscription;

  test("should close connection on disconnect", () async {
    //given
    flutterBlueMock = FlutterBlueMock();
    streamMock = StreamMock<BluetoothDeviceState>();
    connectionSubscription = StreamSubscriptionMock();
    when(streamMock.listen(any)).thenAnswer((_) => connectionSubscription);
    when(flutterBlueMock.connect(any)).thenAnswer((_) => streamMock);

    connectedBleDevice = ConnectedBleDevice.fromDisconnected(BleDeviceFactory.buildDisconnected(flutterBlue: flutterBlueMock), connectionSubscription);

    //when
    connectedBleDevice.disconnect();

    //then
    await untilCalled(connectionSubscription.cancel());
  });
}