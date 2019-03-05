
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:flutter/material.dart';
import 'package:wear_hint/device_details/device_details_bloc.dart';
import 'package:wear_hint/repository/device_repository.dart';

class DeviceDetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeviceDetailsBLoc deviceDetailsBLoc = DeviceDetailsBLoc(FlutterBlue.instance, DeviceRepository());
    return  Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: StreamBuilder<BleDevice>(
        initialData: deviceDetailsBLoc.device.value,
        stream: deviceDetailsBLoc.device,
        builder: (context, snapshot) =>
            Center(
            child: Text(snapshot.data.toString()),
          ),
      )
    );
  }
}