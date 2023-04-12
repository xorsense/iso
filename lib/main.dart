import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

void main() async {
  math.Random rand = math.Random(DateTime.now().millisecondsSinceEpoch);
  final int port = rand.nextInt(8976) + 1024;
  final cascade = Cascade()
      .add(shelf_router.Router()..get('/hello', (r) => Response.ok('Hello.')));
  await shelf_io.serve(
      logRequests().addHandler(cascade.handler), InternetAddress.anyIPv4, port);

  runApp(MyApp(
    port: port,
  ));
}

class MyApp extends StatefulWidget {
  late int port;
  late NetworkInfo info;
  MyApp({super.key, required this.port}) {
    info = NetworkInfo();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text('http server test')),
            body: FutureBuilder(
                future: widget.info.getWifiIP(),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    final location = 'http://${snapshot.data!}:${widget.port}';
                    return Column(children: [
                      const Text('Server Location'),
                      Text(location),
                      QrImage(data: '$location/hello'),
                    ]);
                  }
                  return const Center(
                      child: CircularProgressIndicator(
                    value: null,
                  ));
                })));
  }
}
