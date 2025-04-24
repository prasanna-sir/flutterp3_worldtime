import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart' as geocoding;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(27.7172, 85.3240); // Kathmandu
  bool _isLoading = true;
  LatLng? _destination;
  Set<Marker> _markers = {};
  final location.Location _locationService = location.Location();
  String? _errorMessage;
  String? _currentAddress; // To store the address

  @override
  void initState() {
    super.initState();
    _initializeLocationService();
  }

  Future<void> _initializeLocationService() async {
    try {
      await _getLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
    }

    location.PermissionStatus permission = await _locationService.hasPermission();
    if (permission == location.PermissionStatus.denied) {
      permission = await _locationService.requestPermission();
      if (permission != location.PermissionStatus.granted) {
        throw Exception('Location permissions denied');
      }
    }

    final currentLocation = await _locationService.getLocation();
    setState(() {
      _center = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _getAddressFromCoordinates(_center.latitude, _center.longitude); // Get address from coordinates
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: _center,
          infoWindow: InfoWindow(title: "Your Location", snippet: _currentAddress), // Show address
        ),
      );
      _isLoading = false;
    });
  }

  // Function to convert coordinates to address
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      geocoding.Placemark place = placemarks[0]; // Get the first place
      setState(() {
        _currentAddress = '${place.name}, ${place.locality}, ${place.country}'; // Format address
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Failed to get address';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
  }

  void _onMapTapped(LatLng position) {
    print("tapped location : ${position.latitude}, ${position.longitude}");
    final message = 'Lat: ${position.latitude}, Lng: ${position.longitude}';

    // Show coordinates in a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_currentAddress!)),
    );

    // Show marker at tapped location
    setState(() {
      _destination = position;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: position,
          infoWindow: InfoWindow(
            title: "Tapped Location",
            snippet: _currentAddress,  // Show coordinates for tapped location
          ),
        ),
      );
    });
    _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Location")),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        onTap: _onMapTapped,
      ),
    );
  }
}
