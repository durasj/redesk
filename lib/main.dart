import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReDesk',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.blueGrey),
      home: MyHomePage(title: 'ReDesk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BleManager bleManager = BleManager();
  Peripheral connectedPeripheral;
  PeripheralConnectionState _connectionState;

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var permissionStatus = await Permission.location.request();

      if (permissionStatus != PermissionStatus.granted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  void _up() async {
    if (connectedPeripheral != null) {
      connectedPeripheral.writeCharacteristic(
          "7ad74b14-2692-45b3-89a6-84dc264526f7",
          "4559a45a-41c0-454a-8574-91324d1007c5",
          Uint8List.fromList([85, 80]),
          false);
    }
  }

  void _down() async {
    if (connectedPeripheral != null) {
      connectedPeripheral.writeCharacteristic(
          "7ad74b14-2692-45b3-89a6-84dc264526f7",
          "4559a45a-41c0-454a-8574-91324d1007c5",
          Uint8List.fromList([68, 79, 87, 78]),
          false);
    }
  }

  void _stop() async {
    if (connectedPeripheral != null) {
      connectedPeripheral.writeCharacteristic(
          "7ad74b14-2692-45b3-89a6-84dc264526f7",
          "4559a45a-41c0-454a-8574-91324d1007c5",
          Uint8List.fromList([00]),
          false);
    }
  }

  void _scanAndConnect() async {
    await bleManager.createClient();
    await _checkPermissions();

    bleManager.startPeripheralScan().listen((scanResult) async {
      //Scan one peripheral and stop scanning
      if (scanResult.peripheral.name == 'ReDesk') {
        print(
            "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
        bleManager.stopPeripheralScan();

        Peripheral peripheral = scanResult.peripheral;
        peripheral
            .observeConnectionState(
                emitCurrentValue: true, completeOnDisconnect: false)
            .listen((connectionState) {
          print(
              "Peripheral ${scanResult.peripheral.identifier} connection state is $connectionState");

          if (connectionState == PeripheralConnectionState.connected) {
            peripheral.discoverAllServicesAndCharacteristics();
          }

          setState(() {
            _connectionState = connectionState;
          });
        });
        await peripheral.connect();
        connectedPeripheral = peripheral;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('The desk is: ${_connectionState}'),
            RaisedButton(
              onPressed: _scanAndConnect,
              child: const Text('SCAN AND CONNECT',
                  style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: GestureDetector(
                onLongPress: _up,
                onLongPressUp: _stop,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).buttonColor,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_up),
                    color: Colors.white,
                    iconSize: 36,
                    onPressed: () => {},
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: GestureDetector(
                onLongPress: _down,
                onLongPressUp: _stop,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).buttonColor,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    color: Colors.white,
                    iconSize: 36,
                    onPressed: () => {},
                  ),
                ),
              ),
            ),
            RaisedButton(
              onPressed: _stop,
              child: const Text('STOP', style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
