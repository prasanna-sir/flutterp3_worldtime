import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'SearchPage.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(27.7172, 85.3240); // Default to Kathmandu
  bool _isLoading = true;
  Set<Marker> _markers = {};
  final location.Location _locationService = location.Location();
  String? _errorMessage;
  String? _currentAddress; // Store the fetched address

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) throw Exception('Location services are disabled');
      }

      var permission = await _locationService.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await _locationService.requestPermission();
        if (permission != location.PermissionStatus.granted) {
          throw Exception('Location permissions denied');
        }
      }

      final current = await _locationService.getLocation();
      _center = LatLng(current.latitude!, current.longitude!);
      _markers.add(
        Marker(
          markerId: const MarkerId("current"),
          position: _center,
          infoWindow: InfoWindow(title:"Tapped Location", snippet:_currentAddress),
        ),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _goToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          onLocationSelected: (LatLng selected) {
            mapController.animateCamera(CameraUpdate.newLatLngZoom(selected, 15));
            _getAddressFromCoordinates(selected.latitude, selected.longitude);
            setState(() {
              _markers.removeWhere((m) => m.markerId.value == "searched");
              _markers.add(
                Marker(
                  markerId: const MarkerId("searched"),
                  position: selected,
                  infoWindow: InfoWindow(title: "Searched Location", snippet: _currentAddress),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  // Get the address for the tapped or searched location
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      geocoding.Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.name}, ${place.locality}, ${place.country}';
      });

      // Show the address in a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address: $_currentAddress')),
      );
    } catch (e) {
      setState(() {
        _currentAddress = 'Failed to get address';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get address')),
      );
    }
  }

  void _onMapTapped(LatLng tappedPoint) {
    _getAddressFromCoordinates(tappedPoint.latitude, tappedPoint.longitude);

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "tapped");
      _markers.add(
        Marker(
          markerId: const MarkerId("tapped"),
          position: tappedPoint,
          infoWindow: InfoWindow(title: "Tapped Location", snippet: _currentAddress),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _goToSearch,
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 15),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        onTap: _onMapTapped,
      ),
    );
  }
}
