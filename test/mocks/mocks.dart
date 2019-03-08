
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mockito/mockito.dart';
import 'package:wear_hint/repository/device_repository.dart';

class FlutterBlueMock extends Mock implements FlutterBlue {}
class DeviceRepositoryMock extends Mock implements DeviceRepository {}
class BluetoothDeviceMock extends Mock implements BluetoothDevice {}