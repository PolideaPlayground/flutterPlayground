
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wear_hint/model/ble_device.dart';
import 'package:flutter/material.dart';
import 'package:wear_hint/device_details/device_details_bloc.dart';
import 'package:wear_hint/repository/device_repository.dart';

class DeviceDetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeviceDetailsBloc deviceDetailsBloc = DeviceDetailsBloc(FlutterBlue.instance, DeviceRepository());
    deviceDetailsBloc.init();
    return  Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: StreamBuilder<BleDevice>(
        initialData: deviceDetailsBloc.device.value,
        stream: deviceDetailsBloc.device,
        builder: (context, snapshot) =>
            Center(
            child: Column(
              children: <Widget>[
                Text(snapshot.data.toString()),
                StreamBuilder<double>(
                  initialData: deviceDetailsBloc.ambientTemperature.value,
                  stream: deviceDetailsBloc.ambientTemperature,
                  builder: (context, snapshot) =>
                    Center(
                      child: Text("Temperature:  ${snapshot.data}"),
                    ),
                ),
              ],
            ),
          )
      )
    );
  }
}