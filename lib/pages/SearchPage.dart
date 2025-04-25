import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchPage extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const SearchPage({super.key, required this.onLocationSelected});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _searchLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      List<Location> locations = await locationFromAddress(_controller.text);
      if (locations.isNotEmpty) {
        final LatLng result = LatLng(locations[0].latitude, locations[0].longitude);
        widget.onLocationSelected(result);
        Navigator.pop(context);
      } else {
        setState(() => _error = "Location not found.");
      }
    } catch (e) {
      setState(() => _error = "Error: ${e.toString()}");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Location")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter place name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _searchLocation,
              child: _loading ? const CircularProgressIndicator() : const Text("Search"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
