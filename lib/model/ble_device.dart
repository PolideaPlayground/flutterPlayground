import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleDevice {
  final String name;
  final DeviceIdentifier id;

  BleDevice(this.name, this.id);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) =>
      other is BleDevice && compareAsciiLowerCase(this.id.id, other.id.id) == 0;
}
