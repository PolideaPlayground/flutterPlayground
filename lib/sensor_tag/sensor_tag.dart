
import 'package:wear_hint/model/ble_device.dart';

class SensorTag {
  static const String IR_SERVICE = 'f000aa00-0451-4000-b000-000000000000';
  static const String IR_DATA = "f000aa01-0451-4000-b000-000000000000";
  static const String IR_CONF = "f000aa02-0451-4000-b000-000000000000";

  ConnectedBleDevice _connectedBleDevice;
}