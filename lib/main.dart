import 'package:flutter/material.dart';
import 'package:mapping/views/open_street_map_view.dart';

void main() {
  runApp(const MyApp());
}
// Google Maps API Key
// AIzaSyAGFc05LYmszsK3NHunO_IdzOqwl-Y7UIs

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OpenStreetMapView(),
    );
  }
}
