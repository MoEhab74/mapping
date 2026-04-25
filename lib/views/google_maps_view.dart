import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  // 1- Google Map Controller to control the map and perform actions on it
  // We can use it to move the map, zoom in/out, etc. from code

  // It's like a promise that says "when the map is ready, I'll give you the controller"
  // The <GoogleMapController> part specifies what type of controller we're expecting

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  // Initial camera position
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357), // Cairo, Egypt
    zoom: 12,
  );

  // 2. Define camera positions - these determine where the map is centered and how it looks
  // Think of camera positions like setting up where a camera is pointing in a movie scene

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers = {
      const Marker(
        markerId: MarkerId('marker_1'),
        position: LatLng(30.0444, 31.2357), // Cairo, Egypt
        infoWindow: InfoWindow(title: 'Cairo', snippet: 'The capital of Egypt'),
      ),
      const Marker(
        markerId: MarkerId('marker_2'),
        position: LatLng(30.0131, 31.2089), // Giza, Egypt
        infoWindow: InfoWindow(title: 'Giza', snippet: 'Home of the Pyramids'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 300,
        child: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers,
          // Add these options to ensure proper map loading
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          buildingsEnabled: true,
          trafficEnabled: true,
          // Ensure map is interactive
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
