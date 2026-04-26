import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mapping/functions/show_snack_bar_message.dart';
import 'package:mapping/widgets/search_field_and_icon_button.dart';

class OpenStreetMapView extends StatefulWidget {
  const OpenStreetMapView({super.key});

  @override
  State<OpenStreetMapView> createState() => _OpenStreetMapViewState();
}

class _OpenStreetMapViewState extends State<OpenStreetMapView> {
  // MapController is used to control the map (move to a specific location, zoom in/out, etc.)
  final MapController _mapController = MapController();

  final Location _location =
      Location(); // To Access the device's location
  final TextEditingController _searchController =
      TextEditingController(); // For the search bar
  bool isLoading = true;
  // latlong2 package is used to convert the latitude and longitude to a LatLng object (which is used by the flutter_map package)
  LatLng? _currentLocation;

  // To store the destination location (the location that the user searched for)
  LatLng? _destinationLocation;
  // List of LatLng objects that represent the route
  List<LatLng> _routeCoordinates = [];

  // Initialize location by  asking for permission, listening for location updates, and updating the current location accordingly.
  Future<void> _initializeLocation() async {
    // Check and request location permissions
    // If the permissions is denied, the user will be prompted to grant it.
    //If the user denies the permission, the function will return false and the location updates will not be listened to.
    // And after that here I will just return (Stopping the function execution)
    if (!await _checkRequestPermission()) return;
    // Listen for location updates and update the current location
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
          isLoading = false;
        });
      }
    });
  }

  // services + permissions
  Future<bool> _checkRequestPermission() async {
    // To check if the device has a location service
    bool serviceEnabled = await _location.serviceEnabled();
    // If the location service is not enabled, request the user to enable it
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    // To check if the device has granted permission to access the location
    // It means that the user has not yet granted or denied the permission (Location permission)
    PermissionStatus permissionGranted = await _location.hasPermission();
    // If the permission is denied, request the user to grant it
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // Move the map to the user's current location
  Future<void> _userCurrentLocation() async {
    // Get user's current location using Geolocator or Location package
    // Then move the map to the user's location
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      // Handle the case when location is not available
      showSnackBarMessage(context, 'Unable to get current location');
    }
  }

  

  // Fetch coordinates for a given location using the OpenStreetMap service ===> Nominatim API
  Future<void> _fetchCoordinates(String location) async {
    // Construct the URL to query the OpenStreetMap API
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1&addressdetails=1';
    // Make a GET request to the OpenStreetMap API
    final response = await Dio().get(
      url,
      options: Options(
        headers: {'User-Agent': 'com.abdallahyassin.mapping/1.0'},
      ),
    );
    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> results = response.data;
      if (results.isNotEmpty) {
        final Map<String, dynamic> result = results[0];
        // Extract the latitude and longitude from the result
        final double latitude = double.parse(result['lat']);
        final double longitude = double.parse(result['lon']);
        // Update the state with the new coordinates
        setState(() {
          _destinationLocation = LatLng(latitude, longitude);
        });
        // Display the route from the current location to the destination location
        await _displayRoute();
      }
    } else {
      // Handle the error case
      showSnackBarMessage(context, 'Failed to fetch coordinates for the location');
    }
  }

  // API Key ===> eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQyYTEyNWIzNDc3MDQyMWFhNWQ5OWMzMGZmNjRhYzZjIiwiaCI6Im11cm11cjY0In0=
  final String _apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQyYTEyNWIzNDc3MDQyMWFhNWQ5OWMzMGZmNjRhYzZjIiwiaCI6Im11cm11cjY0In0=';
      
  // Using OpenRouteService API to fetch the route between the current location and the destination location
  // Directions Endpoint
  Future<void> _displayRoute() async {
    if (_currentLocation == null || _destinationLocation == null) {
      showSnackBarMessage(context, 'Current location or destination location is not available');
      return;
    }
    final response = await Dio().get(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_apiKey&start=${_currentLocation!.longitude},${_currentLocation!.latitude}&end=${_destinationLocation!.longitude},${_destinationLocation!.latitude}&geometry_format=geojson',
    );
    if (response.statusCode == 200) {
      // Get the polyline coordinates from the response and convert them to a list of LatLng objects
      final data = response.data;
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        _routeCoordinates = coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
      });
      // Draw route
    } else {
      showSnackBarMessage(context, 'Failed to fetch route');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }
  @override
  void dispose() {    
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
              : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,

                child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation ?? LatLng(0, 0),
                      initialZoom: 2,
                      minZoom: 0,
                      maxZoom: 100,
                    ),
                    children: [
                      TileLayer(
                        // This template is to fetch the Open Street Map tiles from the OpenStreetMap server.
                        // Exists in the flutter_map_location_marker package
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // subdomains: const ['a', 'b', 'c'],
                        // OpenStreetMap specifically blocks 'com.example.*' package names!
                        // We must use a unique identifier.
                        // We should use our app's package name
                        userAgentPackageName: 'com.abdallahyassin.mapping',
                      ),
                      // CurrentLocationLayer = Geolocator + Marker + Live tracking
                      // We use it istead of Geolocator + Marker because it provides a lot of features out of the box like:
                      // - Customizable marker (size, color, icon, etc.)
                      // - Live tracking (the marker will move as the user moves)
                      // Under the hood, this package automatically uses the geolocator plugin.
                      //geolocator makes a very strict check for Google Play Services (the FusedLocationProviderClient) by default.
                      CurrentLocationLayer(
                        alignPositionOnUpdate: AlignOnUpdate.once,
                        alignDirectionOnUpdate: AlignOnUpdate.never,
                        style: const LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            child: Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          markerSize: Size(35, 35),
                          markerDirection: MarkerDirection.heading,
                        ),
                      ),
                      if (_destinationLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _destinationLocation!,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      // Draw the route as a PolylineLayer
                      if (_routeCoordinates.isNotEmpty &&
                          _currentLocation != null &&
                          _destinationLocation != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routeCoordinates,
                              strokeWidth: 4,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                    ],
                  ),
              ),
          // TextField for searching for a location
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SearchFieldAndIconButton(
              searchController: _searchController,
              onPressed: () {
                // Fetch coordinates for the entered location
                if (_searchController.text.isEmpty) {
                  return;
                }
                _fetchCoordinates(_searchController.text);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // Move to user's current location
          _userCurrentLocation();
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

