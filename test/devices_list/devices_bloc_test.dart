
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:wear_hint/devices_list/devices_bloc.dart';
import 'package:wear_hint/model/ble_device.dart';

import '../factory/factory.dart';
import '../mocks/mocks.dart';


void main() {
  test('should emit empty list on startup', () {
    //given
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    DevicesBloc devicesBloc = DevicesBloc(flutterBlueMock);
    when(flutterBlueMock.scan()).thenAnswer((_) => Observable.never());

    //when
    ValueObservable<List<BleDevice>> devicesStream = devicesBloc.visibleDevices;
    devicesBloc.init();

    //then
    expect(devicesStream.value, isEmpty);
    expect(devicesStream.value, <BleDevice>[]);
  });


  test('should return first scanned device', () {
    //given
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    DevicesBloc devicesBloc = DevicesBloc(flutterBlueMock);
    BluetoothDevice bluetoothDevice = BluetoothDeviceFactory.build();
    BleDevice bleDevice = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice);

    when(flutterBlueMock.scan())
        .thenAnswer((_) =>
          Observable.just(
              ScanResultFactory
                .build(bluetoothDevice: bluetoothDevice)
          )
        );

    //then
    expectLater(devicesBloc.visibleDevices, emitsInOrder([
      equals(<BleDevice>[]),
      equals(<BleDevice>[bleDevice])
    ]));

    //when
    devicesBloc.init();
  });

  test("should emit list of all discovered devices", () {
    //given
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    DevicesBloc devicesBloc = DevicesBloc(flutterBlueMock);
    BluetoothDevice bluetoothDevice1 = BluetoothDeviceFactory.build(name: "name1", id: "id1");
    BluetoothDevice bluetoothDevice2= BluetoothDeviceFactory.build(name: "name2", id: "id2");
    BleDevice bleDevice1 = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice1);
    BleDevice bleDevice2 = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice2);

    when(flutterBlueMock.scan())
        .thenAnswer((_) =>
        Observable.fromIterable([
            ScanResultFactory.build(bluetoothDevice: bluetoothDevice1),
            ScanResultFactory.build(bluetoothDevice: bluetoothDevice2),
        ])
    );

    //then
    expectLater(devicesBloc.visibleDevices, emitsInOrder([
      equals(<BleDevice>[]),
      equals(<BleDevice>[bleDevice1]),
      equals(<BleDevice>[bleDevice1, bleDevice2])
    ]));

    //when
    devicesBloc.init();
  });

  test("should not emit twice the same device", () {
    //given
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    DevicesBloc devicesBloc = DevicesBloc(flutterBlueMock);
    BluetoothDevice bluetoothDevice1 = BluetoothDeviceFactory.build(name: "name1", id: "id1");
    BluetoothDevice bluetoothDevice2= BluetoothDeviceFactory.build(name: "name2", id: "id2");
    BleDevice bleDevice1 = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice1);
    BleDevice bleDevice2 = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice2);

    when(flutterBlueMock.scan())
        .thenAnswer((_) =>
        Observable.fromIterable([
          ScanResultFactory.build(bluetoothDevice: bluetoothDevice1),
          ScanResultFactory.build(bluetoothDevice: bluetoothDevice1),
          ScanResultFactory.build(bluetoothDevice: bluetoothDevice2),
        ])
    );

    //then
    expectLater(devicesBloc.visibleDevices, emitsInOrder([
      equals(<BleDevice>[]),
      equals(<BleDevice>[bleDevice1]),
      equals(<BleDevice>[bleDevice1, bleDevice2])
    ]));

    //when
    devicesBloc.init();
  });

  test("should not emit device without local name", () {
    //given
    FlutterBlueMock flutterBlueMock = FlutterBlueMock();
    DevicesBloc devicesBloc = DevicesBloc(flutterBlueMock);
    BluetoothDevice bluetoothDevice1 = BluetoothDeviceFactory.build(name: "name1", id: "id1");
    BluetoothDevice bluetoothDevice2= BluetoothDeviceFactory.build(name: "name2", id: "id2");
    BleDevice bleDevice2 = BleDeviceFactory.buildDisconnected(bluetoothDevice: bluetoothDevice2);

    when(flutterBlueMock.scan())
        .thenAnswer((_) =>
        Observable.fromIterable([
          ScanResultFactory.build(bluetoothDevice: bluetoothDevice1, localName: ""),
          ScanResultFactory.build(bluetoothDevice: bluetoothDevice2),
        ])
    );

    //then
    expectLater(devicesBloc.visibleDevices, emitsInOrder([
      equals(<BleDevice>[]),
      equals(<BleDevice>[bleDevice2]),
    ]));

    //when
    devicesBloc.init();
  });
}