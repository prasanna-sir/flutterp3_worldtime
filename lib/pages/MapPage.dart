import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _center = LatLng(27.7172, 8.3240); // default to Kathmandu
  bool _isLoading = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(_center));
  }

  Future<void> _getLocation() async {
    Location location = Location();
    print('checking service');


    //to check if location service is enabled

    bool servicedEnabled = await location.serviceEnabled();

    if(!servicedEnabled){
      servicedEnabled= await location.requestService();

    }

    if(!servicedEnabled){
      //to handle if user resfuses to enable location service
      print('srvice is not enabled');
      
      return;
    }

      print('check permission');
    //requesting permissions
     PermissionStatus permisssion = await location.hasPermission();
    if (permisssion == PermissionStatus.denied){
      permisssion= await location.requestPermission();

      if (permisssion != PermissionStatus.granted){
          return;
      }
    }


print ('getting current location');
    final currentLocation = await location.getLocation();
    setState(() {
      _center = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Location")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId("currentLocation"),
            position: _center,
          ),
        },
      ),
    );
  }
}
