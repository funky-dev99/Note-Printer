import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:math';
import 'package:intl/intl.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

import 'HomePage.dart';


class PrinterPage extends StatefulWidget {
  final String note;
  PrinterPage({super.key, required this.note, });

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }

  String generatedReceiptId() {
    final random = Random();
    int min = 0; // Smallest 5-digit number
    int max = 99999; // Largest 5-digit number
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber.toString().padLeft(5, '0');
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Bluetooth Printer'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothPrint.startScan(timeout: Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((d) => ListTile(
                    title: Text(d.name??''),
                    subtitle: Text(d.address??''),
                    onTap: () async {
                      setState(() {
                        _device = d;
                      });
                    },
                    trailing: _device!=null && _device!.address == d.address?Icon(
                      Icons.check,
                      color: Colors.green,
                    ):null,
                  )).toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          child: Text('connect'),
                          onPressed:  _connected?null:() async {
                            if(_device!=null && _device!.address !=null){
                              setState(() {
                                tips = 'connecting...';
                              });
                              await bluetoothPrint.connect(_device!);
                            }else{
                              setState(() {
                                tips = 'please select device';
                              });
                              print('please select device');
                            }
                          },
                        ),
                        SizedBox(width: 10.0),
                        OutlinedButton(
                          child: Text('disconnect'),
                          onPressed:  _connected?() async {
                            setState(() {
                              tips = 'disconnecting...';
                            });
                            await bluetoothPrint.disconnect();
                          }:null,
                        ),
                      ],
                    ),
                    Divider(),
                    OutlinedButton(
                      child: Text('Print Receipt'),
                      onPressed:  _connected?() async {
                        print(generatedReceiptId());
                        Map<String, dynamic> config = Map();

                        List<LineText> list = [];


                        list.add(LineText(type: LineText.TYPE_TEXT, content: widget.note, weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                        list.add(LineText(type: LineText.TYPE_TEXT, content: getCurrentDateTime(), weight: 0, align: LineText.ALIGN_CENTER, linefeed: 1));


                        await bluetoothPrint.printReceipt(config, list);
                      }:null,
                    ),

                    OutlinedButton(
                        child: Text('Select Again'),
                        onPressed:  () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()
                            ),
                          );
                        }
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

