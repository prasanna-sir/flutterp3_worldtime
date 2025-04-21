import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/world_time.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  List<WorldTime> locations = [];
  List<WorldTime> filteredLocations = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTimeZones();
  }

  Future<void> fetchTimeZones() async {
    try {
      final response = await http.get(Uri.parse('https://timeapi.io/api/TimeZone/AvailableTimeZones'));
      if (response.statusCode == 200) {
        final List<dynamic> zones = jsonDecode(response.body);

        List<WorldTime> loadedZones = zones.map((zone) {
          final parts = zone.split('/');
          final locationName = parts.length > 2 ? parts[1].replaceAll('_', ' ') : zone;

          return WorldTime(
            url: zone,
            location: locationName,
            flag: 'default.png', // Optional: Replace with flag logic
          );
        }).toList();

        loadedZones.sort((a, b) => a.location.compareTo(b.location));

        setState(() {
          locations = loadedZones;
          filteredLocations = List.from(loadedZones);
        });
      } else {
        throw Exception('Failed to load time zones');
      }
    } catch (e) {
      print("Error fetching zones: $e");
    }
  }

  void updateTime(index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitCubeGrid(
          color: Colors.black,
          size: 50.0,
        ),
      ),
    );

    WorldTime instance = filteredLocations[index];
    await instance.getTime();

    Navigator.pop(context); // remove spinner
    Navigator.pop(context, {
      'location': instance.location,
      'presenttime': instance.presenttime,
      'flag': instance.flag,
      'presentday': instance.presentday,
      'isDayTime': instance.isDayTime,
    });
  }

  void searchLocations(String query) {
    setState(() {
      filteredLocations = locations
          .where((location) =>
          location.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Choose the location"),
        centerTitle: true,
        elevation: 0,
      ),
      body: locations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) => searchLocations(query),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 1, horizontal: 4),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        updateTime(index);
                      },
                      title: Text(filteredLocations[index].location),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/${filteredLocations[index].flag}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
